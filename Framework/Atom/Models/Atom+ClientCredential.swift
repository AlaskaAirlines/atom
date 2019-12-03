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
    /// The `ClientCredential` type declares an object used by Atom for automated refreshing of the access token.
    /// See https://tools.ietf.org/html/RFC6749
    struct ClientCredential {
        /// The authorization grant type as described in Sections 4.1.3, 4.3.2, 4.4.2, RFC 6749. Starting with
        /// version 4.0, Atom supports automated token refresh using `refresh_token` grant type as defined in RFC 6749.
        internal let grantType: GrantType

        /// The client identifier issued to the client during the registration process described in Section 2.2, RFC 6749.
        internal let id: String

        /// The client secret. The client MAY omit the parameter if the client secret is an empty string. See RFC 6749.
        internal let secret: String

        /// Creates a `ClientCredential` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - grantType: The authorization grant type as described in Sections 4.1.3, 4.3.2, 4.4.2, RFC 6749.
        ///   - id:        The client identifier issued to the client during the registration process described by Section 2.2, RFC 6749.
        ///   - secret:    The client secret. The client MAY omit the parameter if the client secret is an empty string. See RFC 6749.
        public init(grantType: GrantType = .refreshToken, id: String, secret: String) {
            self.id = id
            self.grantType = grantType
            self.secret = secret
        }
    }
}
