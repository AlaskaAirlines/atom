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

public extension AtomError {
    /// Returns `Bool` indicating whether the error is due to an invalid or expired access token.
    var isAuthorizationFailure: Bool {
        guard case let .response(response) = self else { return false }

        return response.statusCode == 401
    }

    /// Returns `Bool` indicating whether the error is due to a failed attempt to refresh an access token.
    ///
    /// A client might encouter this error if the authorization server determines that the
    /// refresh token used in a request is invalid or expired.
    ///
    /// Unlike `AtomError` case - `.response` - token refresh error is nested inside of the `.session` error
    /// case to make differentiation between a standard `Bad Request` and `Bad Request` due to an invalid /
    /// or expired access token easier.
    var isAccessTokenRefreshFailure: Bool {
        guard
            case let .session(error) = self,
            case let .response(response) = error as? AtomError
            else { return false }

        return response.statusCode == 400
    }
}

public extension AtomError {
    /// Convenience method for decoding error object or message returned by the service.
    ///
    /// JSON decoder with the default formatting settings and decoding strategies will be used.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///
    /// - Returns: An optional instance of type `T` if `AtomError` is `.response`, and contains valid data, `nil` otherwise.
    func decodeIfPresent<T: Decodable>(as type: T.Type) throws -> T? {
        guard case .response(let response) = self, let data = response.data else { return nil }

        return try JSONDecoder().decode(type, from: data)
    }
}
