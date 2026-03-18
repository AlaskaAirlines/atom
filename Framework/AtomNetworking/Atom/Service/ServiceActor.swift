// AtomNetworking
//
// Copyright (c) 2025 Alaska Airlines
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

// MARK: - ServiceActor

/// Internal actor responsible for executing requests and coordinating token refresh.
actor ServiceActor: Sendable {
    // MARK: - Nested Types

    /// Wraps a `CheckedContinuation` so it can be safely passed across concurrency boundaries.
    final class ContinuationBox<T>: @unchecked Sendable {
        // MARK: - Properties

        /// The underlying continuation to resume.
        let continuation: CheckedContinuation<T, Error>

        // MARK: - Lifecycle

        /// Creates a new wrapper for the provided continuation.
        ///
        /// - Parameters:
        ///   - continuation: The continuation to wrap.
        init(_ continuation: CheckedContinuation<T, Error>) {
            self.continuation = continuation
        }
    }

    // MARK: - Properties

    /// Decoder used for decoding refreshed credentials.
    let credentialDecoder: JSONDecoder

    /// Tracks the currently running refresh task, if one exists.
    var refreshTask: Task<TokenCredential, Error>?

    /// Queue manager used to serialize request execution when a refresh is required.
    let requestableQueueManager: RequestableQueueManager

    /// Configuration used for request execution and authentication.
    let serviceConfiguration: ServiceConfiguration

    /// Shared URLSession used to execute network requests.
    let session: URLSession

    // MARK: - Lifecycle

    /// Creates a new `ServiceActor` with the provided configuration.
    ///
    /// The actor initializes its own `URLSession`, decoder, and queue manager.
    ///
    /// - Parameters:
    ///   - serviceConfiguration: Configuration used for request execution and authentication.
    init(serviceConfiguration: ServiceConfiguration) {
        self.requestableQueueManager = RequestableQueueManager()
        self.serviceConfiguration = serviceConfiguration
        self.credentialDecoder = JSONDecoder()
        self.session = URLSession(
            configuration: serviceConfiguration.sessionConfiguration,
            delegate: Interceptor(for: .network, isEnabled: serviceConfiguration.isLogEnabled),
            delegateQueue: nil
        )
    }
}

// MARK: - Functions

extension ServiceActor {
    /// Applies authorization to the request and executes the provided operation.
    ///
    /// This method ensures the request has the correct authorization header (including handling
    /// token refresh when needed) before invoking the provided `execute` closure.
    ///
    /// - Parameters:
    ///   - requestable: The original request to authorize.
    ///   - completion:  A closure that performs the actual request execution.
    ///
    /// - Returns: The result of the executed request.
    /// - Throws:  `AtomError` if authorization or execution fails.
    func executeAuthorized<T: Sendable>(requestable: any Requestable, completion: @Sendable (any Requestable) async throws(AtomError) -> T) async throws(AtomError) -> T {
        let authorized = try await applyAuthorizationHeader(to: requestable)

        return try await completion(authorized)
    }

    /// Executes a request, serializing execution when a refresh is required.
    ///
    /// If no refresh is needed, the request executes immediately. If a refresh is required or
    /// already in progress, the request is enqueued and resumed once it is safe to proceed.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///   - completion:  A closure that performs the actual network call.
    ///
    /// - Returns: The result of the executed request.
    /// - Throws: `AtomError` if execution fails.
    func performRequest<T: Sendable>(
        for requestable: any Requestable,
        completion: @escaping @Sendable (any Requestable) async throws(AtomError) -> T
    ) async throws(AtomError) -> T {
        if await needsSerialization() {
            return try await withAtomCheckedContinuation { continuation in
                let box: ContinuationBox = .init(continuation)
                requestableQueueManager.enqueue { [requestable, completion, box] in
                    Task {
                        await self.performQueuedRequest(for: requestable, completion: completion, box: box)
                    }
                }
            }
        } else {
            return try await executeAuthorized(requestable: requestable, completion: completion)
        }
    }

    /// Executes a previously queued request and resumes its continuation.
    ///
    /// This method is called when a request was deferred due to serialization. Once execution
    /// completes, the stored continuation is resumed with either the result or the error.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///   - completion:  The closure that performs the network call.
    ///   - box:         The boxed continuation to resume.
    func performQueuedRequest<T: Sendable>(
        for requestable: any Requestable,
        completion: @Sendable (any Requestable) async throws(AtomError) -> T,
        box: ContinuationBox<T>
    ) async {
        do {
            let result = try await executeAuthorized(requestable: requestable, completion: completion)
            box.continuation.resume(returning: result)
        } catch {
            box.continuation.resume(throwing: error)
        }
    }
}
