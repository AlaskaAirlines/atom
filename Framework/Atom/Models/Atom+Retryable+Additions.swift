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

internal extension Atom.Retryable {
    /// Applies authorization header to a `Retryable` request instance.
    ///
    /// - Parameters:
    ///   - method: The authentication method to apply to a `Retryable` request instance.
    ///
    /// Returns: A new `Retryable` instance with applied authorization header.
    func appliedAuthorizationHeader(_ method: Atom.AuthenticationMethod) -> Self {
        var request = self.request
        request.addValue(method.headerValue, forHTTPHeaderField: method.headerField)

        return Atom.Retryable(request: request, requiresAuthorization: requiresAuthorization, completion: completion)
    }
}
