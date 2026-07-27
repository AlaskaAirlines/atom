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

// MARK: - Service

/// Represents a single network request bound to the shared internal actor.
///
/// `Service` captures a `Requestable` and delegates execution to the shared `ServiceActor`, which is responsible for:
/// - Executing the request
/// - Coordinating token refresh
/// - Ensuring only one refresh occurs when multiple requests detect expiration
///
/// A `Service` instance is lightweight and immutable. It does not execute
/// anything until one of the `resume(...)` methods is called.
///
/// ## Concurrency Behavior
/// - All `Service` instances share the same internal actor.
/// - If the token is expired, concurrent callers automatically wait for the same refresh instead of triggering multiple refresh calls.
/// - Both async/await and completion-based APIs route through the same actor, ensuring consistent behavior.
///
/// ## Usage
/// ```swift
/// let result = try await atom.enqueue(MyEndpoint()).resume(expecting: MyModel.self)
/// ```
///
/// Or using completion:
///
/// ```swift
/// atom.enqueue(MyEndpoint()).resume(expecting: MyModel.self) { result in
///     ...
/// }
/// ```
public final class Service: Sendable {
    // MARK: - Properties

    /// Shared internal actor that executes the request and handles token refresh coordination.
    private let serviceActor: ServiceActor

    /// The captured request to execute.
    private let requestable: any Requestable

    // MARK: - Lifecycle

    /// Creates a `Service` bound to the shared actor and a specific request.
    ///
    /// - Parameters:
    ///   - serviceActor: The shared actor responsible for execution.
    ///   - requestable:  The request to execute.
    init(serviceActor: ServiceActor, requestable: any Requestable) {
        self.serviceActor = serviceActor
        self.requestable = requestable
    }

    // MARK: - Functions

    /// Executes the request using async/await and decodes the result.
    ///
    /// If the token is expired, the shared actor ensures only one refresh
    /// occurs and all concurrent callers wait for it.
    ///
    /// - Parameters:
    ///   - type: The expected response model type.
    ///
    /// - Returns: The decoded response.
    public func resume<T>(expecting type: T.Type) async throws(AtomError) -> T where T: Model {
        try await serviceActor.resume(for: requestable, expecting: type)
    }

    /// Executes the request using async/await and returns the raw response.
    ///
    /// - Returns: The raw `AtomResponse`.
    public func resume() async throws(AtomError) -> AtomResponse {
        try await serviceActor.resume(for: requestable)
    }

    /// Executes the request using a completion handler.
    ///
    /// The call is routed through the shared actor to ensure consistent
    /// behavior with async/await usage.
    ///
    /// - Parameters:
    ///   - type:       The expected response model type.
    ///   - completion: Called with the result.
    public func resume<T>(expecting type: T.Type, completion: @Sendable @escaping (Result<T, AtomError>) -> Void) where T: Model {
        Task { await serviceActor.resume(for: requestable, expecting: type, completion: completion) }
    }

    /// Executes the request using a completion handler and returns the raw response.
    ///
    /// - Parameters:
    ///   - completion: Called with the result.
    public func resume(_ completion: @Sendable @escaping (Result<AtomResponse, AtomError>) -> Void) {
        Task { await serviceActor.resume(for: requestable, completion: completion) }
    }
}
