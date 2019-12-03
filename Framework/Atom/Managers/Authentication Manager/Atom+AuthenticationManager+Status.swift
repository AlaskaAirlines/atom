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

internal extension Atom.AuthenticationManager {
    /// List of supported status cases by the `Atom.AuthenticationManager`.
    enum Status {
        /// Authorization header was applied successfully. Set in the following scenarios:
        ///
        /// * Atom applies basic authorization header on behalf of the client.
        /// * Atom applies bearer authorization header on behalf of the client - token is not expired.
        /// * Atom applies bearer authorization header on behalf of the client - token is expired but successfully applied after a refresh.
        case applied(Atom.Retryable)

        /// Application manages its own authorization header.
        case na(Atom.Retryable)

        /// AuthenticationManager is in the process of refreshing an access token.
        case refreshingAccessToken
    }
}
