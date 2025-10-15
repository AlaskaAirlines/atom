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
    /// Asynchronous overload of resume expecting a decodable model type.
    ///
    /// This method enqueues the resume task for FIFO processing via the queue manager and awaits its completion using a checked continuation. It bridges the
    /// completion-based API to async/await, allowing use in modern Swift Concurrency contexts while maintaining serialization.
    ///
    /// - Parameters:
    ///   - type: The expected model type conforming to `Model`.
    ///
    /// - Returns: The decoded model of type `T`.
    /// - Throws: `AtomError` on failure (e.g., network errors or decoding issues).
    public func resume<T>(expecting type: T.Type) async throws(AtomError) -> T where T: Model {
        try await withAtomCheckedContinuation { continuation in
            self.resume(expecting: type) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Asynchronous overload of resume for a raw response, using a provided requestable.
    ///
    /// This method enqueues the resume task for FIFO processing via the queue manager and awaits its completion using a checked continuation. It bridges the
    /// completion-based API to async/await, allowing use in modern Swift Concurrency contexts while maintaining serialization.
    ///
    /// - Returns: The raw `AtomResponse`.
    /// - Throws: `AtomError` on failure (e.g., network errors).
    public func resume() async throws(AtomError) -> AtomResponse {
        try await withAtomCheckedContinuation { continuation in
            self.resume { result in
                continuation.resume(with: result)
            }
        }
    }
}
