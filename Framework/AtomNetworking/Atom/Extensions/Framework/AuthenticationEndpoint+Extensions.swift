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

extension AuthenticationEndpoint {
    /// Header keys, specific to this token refresh request.
    enum HeaderKey {
        static let contentType = "Content-Type"
        static let authorization = "Authorization"
    }

    /// Header values, specific to this token refresh request.
    enum HeaderValue {
        // MARK: - Static Properties

        static let urlEncoded = "application/x-www-form-urlencoded"

        // MARK: - Static Functions

        static func bearer(with writable: TokenCredentialWritable) -> String {
            "Bearer \(writable.tokenCredential.accessToken)"
        }
    }

    /// Body identifiers, specific to this token refresh request.
    enum Identifier {
        static let grantType = "grant_type="
        static let clientID = "client_id="
        static let clientSecret = "client_secret="
        static let refreshToken = "refresh_token="
    }
}

// MARK: - AuthenticationEndpoint + Requestable

extension AuthenticationEndpoint: Requestable {
    var headerItems: [HeaderItem]? { [
        HeaderItem(name: HeaderKey.contentType, value: HeaderValue.urlEncoded),
        HeaderItem(name: HeaderKey.authorization, value: HeaderValue.bearer(with: writable)),
    ] }

    var method: HTTPMethod {
        let grantType = Identifier.grantType.appending(credential.grantType.rawValue)
        let clientID = Identifier.clientID.appending(credential.id)
        let refreshToken = Identifier.refreshToken.appending(writable.tokenCredential.refreshToken)
        var bodyString = grantType + "&" + clientID + "&" + refreshToken

        if let secret = credential.secret {
            bodyString.append("&")
            bodyString.append(Identifier.clientSecret.appending(secret))
        }

        return .post(Data(bodyString.utf8))
    }

    func baseURL() throws(AtomError) -> BaseURL {
        endpoint.baseURL
    }

    func path() throws(AtomError) -> URLPath {
        endpoint.path
    }
}
