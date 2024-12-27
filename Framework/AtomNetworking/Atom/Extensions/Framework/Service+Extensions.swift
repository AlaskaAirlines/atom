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

// MARK: - Helper Properties and Methods

internal extension Service {
    /// Applies authorization header to a `Requestable` instance.
    ///
    /// - Parameters:
    ///   - requestable: The `Requestable` instance to apply authorization header to.
    ///
    /// - Returns: A `Requestable` with authorization header applied (if needed) or pass-through requestable.
    func applyAuthorizationHeader(to requestable: Requestable) async throws(AtomError) -> any Requestable {
        // Get the service configuration's authentication method.
        let method = serviceConfiguration.authenticationMethod

        switch method {
        case .basic:
            // Ensure the requestable requires an authorization header to be applied to it. A client has a
            // way to opt out of including the authorization header on a per-request basis even if the `authenticationMethod` is set.
            guard requestable.requiresAuthorization else {
                return requestable
            }

            // Apply basic authorization header.
            return AuthorizedRequestable(requestable: requestable, authorizationHeaderItems: [method.authorizationHeaderItem])

        case .bearer(let endpoint, let credential, let writable):
            // Ensure the requestable requires an authorization header to be applied to it. A client has a
            // way to opt out of including the authorization header on a per-request basis even if the `authenticationMethod` is set.
            guard requestable.requiresAuthorization else {
                return requestable
            }

            // Ensure the existing credential requires a refresh.
            guard writable.tokenCredential.requiresRefresh else {
                // The credential is valid and does not require a refresh. Apply the access token or credential as an authorization header.
                return AuthorizedRequestable(requestable: requestable, authorizationHeaderItems: [method.authorizationHeaderItem])
            }

            // Refresh the credential.
            let credential = try await refreshAccessToken(using: endpoint, credential: credential, writable: writable)

            // Update the client with a new credential value.
            //
            // Note: This implementation assumes that the token is written to the keychain
            // in a thread-safe manner before it is retrieved by the `writable` instance below.
            writable.tokenCredential = credential

            // Apply access token/credential authorization header.
            return AuthorizedRequestable(requestable: requestable, authorizationHeaderItems: [method.authorizationHeaderItem])

        case .none:
            return requestable
        }
    }

    /// Refreshes the current access token asynchronously.
    ///
    /// This function attempts to refresh the access token if it has expired or is about to expire. It communicates with an
    /// authentication service to get a new token and stores it securely (presumably in a keychain or similar secure storage).
    ///
    /// - Parameters:
    ///   - endpoint:   The endpoint for refreshing the access token.
    ///   - credential: The client credentials to be encoded in the body of the request.
    ///   - writable:   The writable instance used for accessing the existing access token.
    ///
    /// - Returns: A `TokenCredential` object representing the new credential.
    ///
    /// - Throws: An `AtomError` if there's an issue during the refresh process.
    func refreshAccessToken(using endpoint: AuthorizationEndpoint, credential: ClientCredential, writable: any TokenCredentialWritable) async throws(AtomError) -> TokenCredential {
        let authenticationEndpoint = AuthenticationEndpoint(endpoint: endpoint, credential: credential, writable: writable)
        let response = try await session.data(for: authenticationEndpoint)

        return try credentialDecoder.decode(type: TokenCredential.self, from: response.data)
    }
}
