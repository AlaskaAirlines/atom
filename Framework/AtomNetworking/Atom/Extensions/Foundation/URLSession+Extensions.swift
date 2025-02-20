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

extension URLSession {
    /// Convenience method to load data using a `Requestable`, creates and resumes a `URLRequest` internally.
    ///
    /// - Parameters:
    ///   - requestable: The requestable for which to load data.
    ///
    /// - Returns: `AtomResponse` instance containing `Data` and `HTTPURLResponse`.
    ///
    /// - Throws: An error if request initialization fails, if URLSession returns an error, or if the response is invalid.
    func data(for requestable: Requestable) async throws(AtomError) -> AtomResponse {
        do {
            let request = try URLRequest(requestable: requestable)
            let (data, response) = try await data(for: request)
            let atomResponse: AtomResponse = .init(data: data, response: response)

            // Process the response returned by the service, ensuring it falls within the expected range.
            guard atomResponse.isSuccess else {
                // Create an error that includes the response object.
                let error: AtomError = .response(atomResponse)

                // Checks if the error is related to:
                //
                // - Token Refresh Failure: Posts `Atom.didFailToRefreshAccessToken` notification.
                // - Authorization Failure: Posts `Atom.didFailToAuthorizeRequest` notification.
                //
                // Both notifications include the error in `userInfo`.
                if error.isAccessTokenRefreshFailure {
                    // Notify observers that a token refresh has failed.
                    NotificationCenter.default.post(name: Atom.didFailToRefreshAccessToken, object: nil, userInfo: ["error": error])
                } else if error.isAuthorizationFailure {
                    // Notify observers that request authorization has failed.
                    NotificationCenter.default.post(name: Atom.didFailToAuthorizeRequest, object: nil, userInfo: ["error": error])
                }

                throw error
            }

            return atomResponse

        } catch let error as AtomError {
            // Rethrow the error that occurred. This happens when URLRequest initialization fails.
            throw error

        } catch {
            // Creates and throws an AtomError with the URLSession error.
            throw .session(error)
        }
    }
}
