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

    /// Convenience method for decoding error object or message returned by the service.
    ///
    /// JSON decoder with the default formatting settings and decoding strategies will be used.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///
    /// - Returns: An optional instance of type `T` if `AtomError` is `.response`, and contains valid data, `nil` otherwise.
    func decodeIfPresent<T: Decodable>(as type: T.Type) throws -> T? {
        guard case .response(let response) = self else { return nil }

        // Atom supports returning raw data without decoding when the error object structure in not known.
        guard let value = response.data as? T else {
            return try JSONDecoder().decode(type, from: response.data)
        }

        return value
    }
}

// MARK: - Protocol Conformance

extension AtomError: StringConvertible {
    internal var stringValue: String {
        switch self {
        case .decoder:
            return "decoder"
        case .requestable:
            return "requestable"
        case .response:
            return "response"
        case .session:
            return "session"
        case .unexpected:
            return "unexpected"
        }
    }
}

extension AtomError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .decoder(let error):
            return "🧨 JSONDecoder failed to decode the response. This is usually due to a mismatch between the response and the expected type. 💥 Error: \(error)"
        case .requestable(let error):
            return "🧨 Atom failed to initialize a request. This is usually due to an invalid base URL or path. Double-check the Requestable implementation. 💥 Error: \(error)"
        case .response(let error):
            return "🧨 Atom received an invalid response that is not in the 200-299 range. 💥 Error: \(error)"
        case .session(let error):
            return "🧨 URLSession failed to resume a request due to an error. 💥 Error: \(error)"
        case .unexpected:
            return "🧨 Unexpected logic error. Please submit an issue on GitHub."
        }
    }
}
