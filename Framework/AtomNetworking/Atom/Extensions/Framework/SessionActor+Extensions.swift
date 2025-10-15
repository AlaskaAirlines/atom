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

extension SessionActor {
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

        case let .bearer(endpoint, credential, writable):
            // Ensure the requestable requires an authorization header to be applied to it. A client has a
            // way to opt out of including the authorization header on a per-request basis even if the `authenticationMethod` is set.
            guard requestable.requiresAuthorization else {
                return requestable
            }

            // Ensure the existing credential requires a refresh.
            if writable.tokenCredential.requiresRefresh {
                if let refreshTask {
                    // Await the ongoing refresh Task to ensure completion before proceeding.
                    writable.tokenCredential = try await refreshTask.typedValue()
                }

                else {
                    // If isRefreshing but no task yet (race window), wait briefly.
                    var pollCount = 0

                    // Poll loop to handle potential race where flag is set but Task not yet assigned.
                    while isRefreshing, refreshTask == nil, pollCount < 10 {
                        pollCount += 1

                        // Sleep briefly to allow the other call to assign the refreshTask.
                        try? await Task.sleep(for: .milliseconds(10))
                    }

                    // After polling, check if the refreshTask is now available and await it if so.
                    if let refreshTask {
                        writable.tokenCredential = try await refreshTask.typedValue()
                    }

                    // If no Task after polling, initiate a new refresh.
                    else {
                        // Set the flag to block other concurrent calls from starting a duplicate refresh.
                        isRefreshing = true

                        // Create a new Task for the background refresh operation.
                        refreshTask = Task {
                            // Ensure the flag and task reference are reset after completion or failure.
                            defer {
                                isRefreshing = false
                                refreshTask = nil
                            }

                            // Perform the actual token refresh and return the new credential.
                            return try await refreshAccessToken(using: endpoint, credential: credential, writable: writable)
                        }

                        // Await the new Task's result and assign if successful, or throw on failure.
                        if let value = try await refreshTask?.typedValue() {
                            writable.tokenCredential = value
                        }
                    }
                }
            }

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
    func refreshAccessToken(
        using endpoint: AuthorizationEndpoint,
        credential: ClientCredential,
        writable: any TokenCredentialWritable
    ) async throws(AtomError) -> TokenCredential {
        let authenticationEndpoint: AuthenticationEndpoint = .init(endpoint: endpoint, credential: credential, writable: writable)
        let response = try await session.data(for: authenticationEndpoint)

        return try credentialDecoder.decode(type: TokenCredential.self, from: response.data)
    }
}
