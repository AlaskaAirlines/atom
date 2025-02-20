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

/// A structure representing an authentication endpoint.
struct AuthenticationEndpoint: Sendable {
    // MARK: - Properties

    /// The endpoint for refreshing the access token.
    let endpoint: AuthorizationEndpoint

    /// The client credentials to be encoded in the body of the request.
    let credential: ClientCredential

    /// The writable instance used for accessing the existing access token.
    let writable: any TokenCredentialWritable

    // MARK: - Lifecycle

    /// Creates a `AuthenticationEndpoint` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - endpoint:   The endpoint for refreshing the access token.
    ///   - credential: The client credentials to be encoded in the body of the request.
    ///   - writable:   The writable instance used for accessing the existing access token.
    init(endpoint: AuthorizationEndpoint, credential: ClientCredential, writable: any TokenCredentialWritable) {
        self.endpoint = endpoint
        self.credential = credential
        self.writable = writable
    }
}
