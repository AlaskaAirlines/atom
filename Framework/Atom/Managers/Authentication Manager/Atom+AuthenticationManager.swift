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

/// The `AuthenticationManagerDelegate` protocol provides an interface for responding to `AuthenticationManager` events.
internal protocol AuthenticationManagerDelegate: class {
    /// Notifies the delegate when the `AuthenticationManager` successfully refreshed the access token.
    func authenticationManagerDidRefreshAccessToken()

    /// Notifies the delegate when the `AuthenticationManager` failed to refresh the access token.
    func authenticationManagerDidFailToRefreshAccessTokenWithError(_ error: AtomError)
}

internal extension Atom {
    /// The `AuthenticationManager` object used by Atom for automated refreshing of the access token.
    final class AuthenticationManager {
        /// The delegate to notify of `AuthenticationManager` events.
        private unowned let delegate: AuthenticationManagerDelegate

        /// Indicates whether the `AuthenticationManager` is in the process of refreshing access token.
        private var isRefreshing = false

        /// The `URLSession` instance used for token refresh.
        private let session: URLSession

        /// The authentication method to apply to a request.
        private let method: Atom.AuthenticationMethod

        /// Creates a `AuthenticationManager` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - method:   The authentication method to apply to a request.
        ///   - delegate: The delegate to notify of `AuthenticationManager` events.
        internal init(_ method: Atom.AuthenticationMethod, delegate: AuthenticationManagerDelegate) {
            self.method = method
            self.delegate = delegate
            self.session = URLSession(configuration: .default, delegate: Interceptor(for: .authentication), delegateQueue: .main)
        }
    }
}

internal extension Atom.AuthenticationManager {
    /// Applies authorization header to a `Retryable` instance.
    ///
    /// - Parameters:
    ///   - retryable: The `Retryable` instance to apply authorization header to.
    ///
    /// - Returns: A `Status` instance indicating whether authorization header was applied.
    func applyAuthorizationHeader(to retryable: Atom.Retryable, on queue: DispatchQueue) -> Status {
        switch method {
        case .basic:
            // Client does not need authorization header applied for this request.
            if !retryable.requiresAuthorization {
                return .na(retryable)
            }

            // Apply basic authorization header.
            else { return .applied(retryable.appliedAuthorizationHeader(method)) }

        case .bearer(_, _, let writable):
            // Access token has expired and is currently refreshing.
            if isRefreshing {
                return .refreshingAccessToken
            }

            // Client does not need authorization header applied for this request.
            else if !retryable.requiresAuthorization {
                return .na(retryable)
            }

            // Access token has expired and the request requires authentication, will attempt to refresh.
            else if !isRefreshing, writable.tokenCredential.requiresRefresh, retryable.requiresAuthorization {
                refreshAccessToken(writable, queue: queue)
                return .refreshingAccessToken

            // Access token is valid and request requires authorization - apply authorization header.
            } else if !writable.tokenCredential.requiresRefresh, retryable.requiresAuthorization {
                return .applied(retryable.appliedAuthorizationHeader(method))

            // Access token is valid but request does not require authorization.
            } else { return .na(retryable) }

        case .none:
            return .na(retryable)
        }
    }
}

// MARK: Token Refresh

private extension Atom.AuthenticationManager {
    /// Will refresh existing access token using defined endpoint.
    func refreshAccessToken(_ writable: TokenCredentialWritable, queue: DispatchQueue) {
        unowned let unownedSelf = self

        // Update `isRefreshing` property.
        unownedSelf.isRefreshing = true

        // Create a `URLRequest` for token refresh network call.
        guard let request = method.tokenRefreshRequest else {
            return queue.async {
                unownedSelf.delegate.authenticationManagerDidFailToRefreshAccessTokenWithError(.unexpected)
                unownedSelf.isRefreshing = false
            }
        }

        // Resume data task.
        session.dataTask(with: request) { data, response, error in
            // Process error returned by the service.
            if let error = error {
                queue.async { unownedSelf.delegate.authenticationManagerDidFailToRefreshAccessTokenWithError(.session(error)) }
            }

            // Process error response returned by the service.
            else if response?.isFailure == true {
                queue.async { unownedSelf.delegate.authenticationManagerDidFailToRefreshAccessTokenWithError(.response(Atom.Response(data, response))) }
            }

            // Process data returned by the service.
            else if let data = data {
                do {
                    // Decode token from data on the background queue and update the client with new token credentials.
                    writable.tokenCredential = try JSONDecoder().decode(Atom.TokenCredential.self, from: data)

                    // Notify the delegate of successful token refresh.
                    queue.async { unownedSelf.delegate.authenticationManagerDidRefreshAccessToken() }

                } catch {
                    // Notify the delegate of the decoding error returned by `JSONDecoder`.
                    queue.async { unownedSelf.delegate.authenticationManagerDidFailToRefreshAccessTokenWithError(.decoder(error)) }
                }
            }

            // Neither error, response nor data returned. Notify the delegate of the `unknown` error.
            else { queue.async { unownedSelf.delegate.authenticationManagerDidFailToRefreshAccessTokenWithError(.unknown) } }

            // Update `isRefreshing` property.
            unownedSelf.isRefreshing = false
        }.resume()
    }
}
