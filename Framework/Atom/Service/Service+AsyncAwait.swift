// Atom
//
// Copyright (c) 2021 Alaska Airlines
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

@available(iOS 15.0, macOS 12.0, *)
public extension Service {
    /// Creates and resumes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you expect data returned by the
    /// service and require that data to be decoded into internal representations - models.
    ///
    /// Network request and decoding will be performed on a background thread after
    /// which the client will be notified on a queue `Atom` was configured to use.
    ///
    /// A typical usage pattern for this method could look like this:
    ///
    /// ```
    /// let user = try await atom
    ///     .enqueue(endpoint)
    ///     .resume(expecting: User.self)
    /// ```
    ///
    /// In the above example, data will be decoded into a `User` instance.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///
    /// - Throws: `AtomError` instance if an error occurred.
    ///
    /// - Returns: Decoded `Model` instance.
    func resume<T>(expecting type: T.Type) async throws -> T where T: Model {
        try await withCheckedThrowingContinuation { continuation in
            self.resume(expecting: type) {
                continuation.resume(with: $0)
            }
        }
    }

    /// Creates and resumes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you don't expect any data returned
    /// and are only interested in knowing if the network call succeeded or failed.
    ///
    /// `Atom` framework uses a convenience computed variable on `AtomResponse` - `isSuccessful`
    /// to determine success or a failure of a response based on a status code returned by the service.
    ///
    /// A typical usage pattern for this method could look like this:
    ///
    /// ```
    /// let response = try await atom
    ///     .enqueue(endpoint)
    ///     .resume()
    /// ```
    ///
    /// - Throws: `AtomError` instance if an error occurred.
    ///
    /// - Returns: `AtomResponse` instance.
    func resume() async throws -> AtomResponse {
        try await withCheckedThrowingContinuation { continuation in
            self.resume {
                continuation.resume(with: $0)
            }
        }
    }
}
