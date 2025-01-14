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

internal extension TokenCredential {
    /// Returns `Bool` indicating whether the credential needs refreshing.
    var requiresRefresh: Bool { expiresAt <= .now }
}

// MARK: - Protocol Conformance

extension TokenCredential: Model {
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case expiresAt = "expires_at"
        case refreshToken = "refresh_token"
    }

    /// Initializes an instance by decoding from a decoder, handling both local and service-sourced token data.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws:
    ///   - `DecodingError.dataCorruptedError` if neither `expiresAt` nor `expiresIn` can be decoded.
    ///
    /// - Note: Local Data: If `expiresAt` is present, it suggests the data was previously saved locally. The value of `expiresAt` is directly assigned to `self.expiresAt`.
    /// - Note: Service Data: If `expiresAt` is not present but `expiresIn` is, it indicates the data is fresh from a service. Here, `expiresAt` is calculated using `Date.now` plus the number of seconds in `expiresIn`.
    /// - Note: Error Case: If neither `expiresAt` nor `expiresIn` can be decoded, an error is thrown.
    ///
    /// - Note: This initializer assumes that either `expiresAt` or `expiresIn` will be present in the decoded data. If neither is present, it results in an error since token expiration information is crucial.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let expiresAt = try container.decodeIfPresent(Date.self, forKey: .expiresAt)
        let expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)

        // If `expiresAt` contains a value, it suggests that a local function called
        // the decoder to process data previously saved locally. An example would be decoding a previously
        // saved token from data stored in the iOS Keychain.
        if let expiresAt {
            self.expiresAt = expiresAt

        // If expiresIn has a value, it indicates that the decoder is processing data received from a service.
        } else if let expiresIn {
            self.expiresAt = Date.now.addingTimeInterval(Double(expiresIn))

        // An error occured.
        } else {
            throw DecodingError.dataCorruptedError(forKey: .expiresIn, in: container, debugDescription: .init())
        }

        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }

    /// Encodes this instance into an encoder, saving the `accessToken`, `expiresAt`, and `refreshToken`.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding any of the properties fails.
    ///
    /// - Note: This method does not encode `expiresIn` since it's derived from `expiresAt` during decoding. Ensure that `expiresAt` is set correctly before encoding to reflect the accurate expiration time.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encode(refreshToken, forKey: .refreshToken)
    }
}
