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

// MARK: Authorization Values

internal extension Atom.AuthenticationMethod {
    /// Returns "Authorization" as the header field name.
    var headerField: String { "Authorization" }

    /// Returns authorization value based on specified method case.
    var headerValue: String {
        switch self {
        case .basic(let credential):
            return "Basic \(credential.combined.base64)"
        case .bearer(_, _, let writable):
            return "Bearer \(writable.tokenCredential.accessToken)"
        case .none:
            return String()
        }
    }
}

// MARK: Network Request

internal extension Atom.AuthenticationMethod {
    /// Returns `URLRequest` instance used for refreshing a token.
    var tokenRefreshRequest: URLRequest? {
        guard
            case .bearer(let endpoint, let clientCredential, let writable) = self,
            let url = URL(string: endpoint.baseURL.stringValue.appending(endpoint.path.stringValue))
            else { return nil }

        let grantType = Identifier.grantType.appending(clientCredential.grantType.rawValue)
        let clientId = Identifier.clientId.appending(clientCredential.id)
        let clientSecret = Identifier.clientSecret.appending(clientCredential.secret)
        let refreshToken = Identifier.refreshToken.appending(writable.tokenCredential.refreshToken)
        let bodyString = grantType + "&" + clientId + "&" + clientSecret + "&" + refreshToken

        // Create URL request.
        var request = URLRequest(url: url)
        request.httpMethod = Self.httpMethod
        request.addValue(HeaderValue.urlEncoded, forHTTPHeaderField: HeaderKey.contentType)
        request.addValue(headerValue, forHTTPHeaderField: headerField)
        request.httpBody = bodyString.data(using: .utf8)

        return request
    }

// MARK: Keys, Values & Indetifiers

    /// HTTP method, specific to this token refresh request.
    private static let httpMethod = "POST"

    /// Header keys, specific to this token refresh request.
    private struct HeaderKey {
        static let contentType = "Content-Type"
    }

    /// Header values, specific to this token refresh request.
    private struct HeaderValue {
        static let urlEncoded = "application/x-www-form-urlencoded"
    }

    /// Body identifiers, specific to this token refresh request.
    private struct Identifier {
        static let grantType = "grant_type="
        static let clientId = "client_id="
        static let clientSecret = "client_secret="
        static let refreshToken = "refresh_token="
    }
}
