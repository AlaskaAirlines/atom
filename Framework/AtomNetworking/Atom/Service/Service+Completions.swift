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

extension Service {
    /// Completion-based overload of resume expecting a decodable model type.
    ///
    /// This method enqueues the resume task for FIFO processing via the queue manager, invoking the completion asynchronously with the result. It supports non-async
    /// contexts (e.g., UIKit) while ensuring serialized execution to prevent races on shared state. The task awaits the session actor's resume operation internally.
    ///
    /// - Parameters:
    ///   - type:       The expected model type conforming to `Model`.
    ///   - completion: A `@Sendable` escaping closure called with the result (success with the decoded model or failure with `AtomError`).
    public func resume<T>(expecting type: T.Type, completion: @Sendable @escaping (Result<T, AtomError>) -> Void) where T: Model {
        requestableQueueManager.enqueue { [weak self, completion] in
            guard let self else {
                return
            }

            do {
                // Perform the async resume operation on the session actor.
                let value = try await sessionActor.resume(expecting: type)

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
    /// This method enqueues the resume task for FIFO processing via the queue manager, invoking the completion asynchronously with the result. It supports non-async
    /// contexts (e.g., UIKit) while ensuring serialized execution to prevent races on shared state. The task awaits the session actor's resume operation internally.
    ///
    /// - Parameters:
    ///   - completion: A `@Sendable` escaping closure called with the result (success with `AtomResponse` or failure with `AtomError`).
    public func resume(_ completion: @Sendable @escaping (Result<AtomResponse, AtomError>) -> Void) {
        requestableQueueManager.enqueue { [weak self, completion] in
            guard let self else {
                return
            }

            do {
                // Perform the async resume operation on the session actor.
                let value = try await sessionActor.resume()

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
