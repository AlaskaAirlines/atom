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
    /// List of authentication methods a client can choose from for `Atom` configuration.
    enum AuthenticationMethod {
        /// Atom will apply basic authorization header to a request on behalf of the client.
        ///
        /// To apply authorization header, Atom needs access to user's credentials required as `BasicCredential` (associated value).
        case basic(BasicCredential)

        /// Atom will manage access token expiration and apply authorization header to a request on behalf of the client.
        ///
        /// To apply authorization header, Atom needs access to client's credentials required as `ClientCredential` (associated value)
        /// and the location where to save / read from / updated credentials required as `TokenCredentialWritable` (associated value). In addition, a
        /// valid `AuthorizationEndpoint` - the location of the authorization server must be provided (associated value).
        case bearer(AuthorizationEndpoint, ClientCredential, TokenCredentialWritable)

        /// Application will manage its own authorization headers.
        case none
    }
}
