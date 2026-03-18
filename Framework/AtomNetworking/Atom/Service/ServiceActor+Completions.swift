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
    /// Completion-based overload of resume expecting a decodable model type.
    ///
    /// This method delegates execution to the shared actor and invokes the completion asynchronously with the result. It supports non-async
    /// contexts (e.g., UIKit) while ensuring consistent behavior under concurrent load.
    ///
    /// If a token refresh is required, concurrent callers automatically wait for the same refresh task before the request executes.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///   - type:        The expected model type conforming to `Model`.
    ///   - completion:  A `@Sendable` escaping closure called with the result.
    func resume<T: Model>(for requestable: any Requestable, expecting type: T.Type, completion: @Sendable @escaping (Result<T, AtomError>) -> Void) {
        Task {
            do {
                // Perform the async resume operation on the session actor.
                let value = try await resume(for: requestable, expecting: type)

                // Dispatch the success completion asynchronously to the specified queue (e.g., for UI/main thread safety).
                serviceConfiguration.dispatchQueue.async {
                    completion(.success(value))
                }
            } catch {
                // Map and dispatch the failure completion asynchronously, converting generic errors to AtomError.
                serviceConfiguration.dispatchQueue.async {
                    completion(.failure((error as? AtomError) ?? .unexpected))
                }
            }
        }
    }

    /// Completion-based overload of resume for a raw response.
    ///
    /// This method delegates execution to the shared actor and invokes the completion asynchronously with the result. It allows use in non-async
    /// contexts while maintaining the same refresh coordination behavior as async/await usage.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///   - completion:  A `@Sendable` escaping closure called with the result.
    func resume(for requestable: any Requestable, completion: @Sendable @escaping (Result<AtomResponse, AtomError>) -> Void) {
        Task {
            do {
                // Perform the async resume operation on the session actor.
                let value = try await resume(for: requestable)

                // Dispatch the success completion asynchronously to the specified queue (e.g., for UI/main thread safety).
                serviceConfiguration.dispatchQueue.async {
                    completion(.success(value))
                }
            } catch {
                // Map and dispatch the failure completion asynchronously, converting generic errors to AtomError.
                serviceConfiguration.dispatchQueue.async {
                    completion(.failure((error as? AtomError) ?? .unexpected))
                }
            }
        }
    }
}
