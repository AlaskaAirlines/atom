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

// MARK: - De-duplication

extension ServiceActor {
    /// Executes a request, coalescing identical concurrent GETs into a single transport call.
    ///
    /// GET requests are keyed by their pre-auth identity. If a matching request is already in flight, the
    /// caller awaits its result rather than issuing a new one. A request opts out of coalescing
    /// either by using a non-GET method (side effecting requests should never be collapsed) or by
    /// returning `allowsDeduplication == false`.
    ///
    /// The shared work runs in an unstructured `Task`, so cancelling one caller does not cancel the
    /// underlying request - other callers awaiting the same result still receive it. The in-flight entry is
    /// removed once the originating call finishes.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///
    /// - Returns: The raw `AtomResponse`.
    /// - Throws: `AtomError` on failure, propagated to every caller awaiting the same in-flight request.
    func deduplicatedResponse(for requestable: any Requestable) async throws(AtomError) -> AtomResponse {
        // Only GETs are combined. A request may also opt out explicitly via `allowsDeduplication`.
        guard requestable.method == .get, requestable.allowsDeduplication else {
            return try await transportResponse(for: requestable)
        }

        let key = try requestKey(for: requestable)

        // An identical request is already running - join it.
        if let inFlight = inFlightRequests[key] {
            return try await inFlight.typedValue()
        }

        // Create, store, and ensure removal once we finish.
        let task = Task<AtomResponse, Error> {
            try await self.transportResponse(for: requestable)
        }

        inFlightRequests[key] = task

        defer { inFlightRequests[key] = nil }

        return try await task.typedValue()
    }

    /// Runs the request through the existing authorize-then-execute pipeline and returns the raw response.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///
    /// - Returns: The raw `AtomResponse`.
    ///
    /// - Throws: `AtomError` on failure.
    func transportResponse(for requestable: any Requestable) async throws(AtomError) -> AtomResponse {
        try await performRequest(for: requestable) { @Sendable (authorized: any Requestable) async throws(AtomError) -> AtomResponse in
            try await self.session.data(for: authorized)
        }
    }

    /// Derives the de-duplication key from the pre-authorization request.
    ///
    /// Reuses `URLRequest(requestable:)` so the URL is resolved exactly as it will be on the wire (scheme, host,
    /// path, and query items). Header items — including any `Authorization` header applied later by `executeAuthorized` -
    /// are deliberately not part of the key.
    ///
    /// - Parameters:
    ///   - requestable: The pre-auth request to key.
    ///
    /// - Returns: A `RequestKey` uniquely identifying the request for coalescing.
    ///
    /// - Throws: `AtomError` if the URL fails to resolve.
    func requestKey(for requestable: any Requestable) throws(AtomError) -> RequestKey {
        let request = try URLRequest(requestable: requestable)

        return RequestKey(
            method: request.httpMethod ?? requestable.method.stringValue,
            url: request.url?.absoluteString ?? .empty
        )
    }
}
