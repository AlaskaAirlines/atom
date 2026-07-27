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

extension ServiceActor {
    /// Asynchronous overload of resume expecting a decodable model type.
    ///
    /// This method delegates execution to the shared actor, which coordinates request execution and token refresh
    /// when needed. If a refresh is required, concurrent callers automatically wait for the same refresh
    /// task before proceeding.
    ///
    /// This allows use in modern Swift Concurrency contexts while ensuring
    /// consistent behavior under parallel load.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///   - type:        The expected model type conforming to `Model`.
    ///
    /// - Returns: The decoded model of type `T`.
    /// - Throws:  `AtomError` on failure (e.g., network errors or decoding issues).
    func resume<T: Model>(for requestable: any Requestable, expecting type: T.Type) async throws(AtomError) -> T {
        try await performRequest(for: requestable) { @Sendable (authorized: any Requestable) async throws(AtomError) -> T in
            let response = try await self.session.data(for: authorized)

            guard let value = response.data as? T else {
                return try self.serviceConfiguration.decoder.decode(type: type, from: response.data)
            }

            return value
        }
    }

    /// Asynchronous overload of resume for a raw response.
    ///
    /// This method delegates execution to the shared actor, which manages request execution and token refresh coordination.
    /// If a refresh is in progress, callers automatically wait before the request is executed.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///
    /// - Returns: The raw `AtomResponse`.
    /// - Throws:  `AtomError` on failure (e.g., network errors).
    func resume(for requestable: any Requestable) async throws(AtomError) -> AtomResponse {
        try await performRequest(for: requestable) { @Sendable (authorized: any Requestable) async throws(AtomError) -> AtomResponse in
            try await self.session.data(for: authorized)
        }
    }
}
