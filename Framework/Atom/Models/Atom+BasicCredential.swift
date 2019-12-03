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

public extension Atom {
    /// The `BasicCredential` type declares an object used by Atom in network requests that require basic authentication. Before
    /// basic authentication is applied as Authorization header value, username and password will be combined into a single
    /// string using `:` and base 64 encoded.
    struct BasicCredential {
        /// The password to encode and use when applying basic authentication to a request.
        internal let password: String

        /// The username to encode and use when applying basic authentication to a request.
        internal let username: String

        /// Creates a `BasicCredential` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - password: The password to encode and use when applying basic authentication to a request.
        ///   - username: The username to encode and use when applying basic authentication to a request.
        public init(password: String, username: String) {
            self.password = password
            self.username = username
        }
    }
}
