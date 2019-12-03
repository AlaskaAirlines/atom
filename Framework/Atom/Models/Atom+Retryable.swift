// Atom
//
// Copyright (c) 2019 Alaska Airlines
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

internal extension Atom {
    /// A model type representing a network request type that can be retried.
    ///
    /// Each `URLRequest` instance, before being executed, will be converted to `Retryable`
    /// instance and enqueued for network call execution. This is done to provide a manageable
    /// way for Atom to inspect and retry each request ensuring valid Authorization header value(s)
    /// are applied where needed. See `Atom.AuthenticationPreference` and `Requestable` for more information.
    ///
    /// Atom implementation ensures valid access token is applied to a request before executing it. If Atom
    /// determines that a token refresh is required, all calls will be collected and suspended without execution
    /// until new token is obtained using defined endpoint. Once a new token is obtained, all suspended requests
    /// will be resumed at once.
    struct Retryable {
        internal typealias Completion = (Data?, URLResponse?, Error?) -> Void

        /// The `URLRequest` instance to retry.
        internal let request: URLRequest

        /// The `Bool` indicating whether or not authorization header should be applied.
        internal let requiresAuthorization: Bool

        /// The completion block for retried requests.
        internal let completion: Completion

        /// Creates a `Retryable` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - request:               The `URLRequest` instance to retry.
        ///   - requiresAuthorization: The `Bool` indicating whether or not authorization header should be applied.
        ///   - completion:            The completion block for retried requests.
        internal init(request: URLRequest, requiresAuthorization: Bool, completion: @escaping Completion) {
            self.request = request
            self.requiresAuthorization = requiresAuthorization
            self.completion = completion
        }
    }
}
