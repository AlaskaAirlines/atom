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

@testable import AtomNetworking
import XCTest

internal final class TokenCredentialTests: XCTestCase {
    internal func testInitializeWithRequiredValues() {
        // Given
        let accessToken = "accessToken"
        let expiresAt = Date()
        let refreshToken = "refreshToken"

        // When
        let tokenCredential = TokenCredential(accessToken: accessToken, expiresAt: expiresAt, refreshToken: refreshToken)

        // Then
        XCTAssertEqual(tokenCredential.accessToken, accessToken)
        XCTAssertEqual(tokenCredential.expiresAt, expiresAt)
        XCTAssertEqual(tokenCredential.refreshToken, refreshToken)
    }

    internal func testEncodeAndDecode() throws {
        // Given
        let accessToken = "accessToken"
        let expiresAt = Date()
        let refreshToken = "refreshToken"
        let tokenCredential = TokenCredential(accessToken: accessToken, expiresAt: expiresAt, refreshToken: refreshToken)

        // When
        let encoded = try JSONEncoder().encode(tokenCredential)
        let decoded = try JSONDecoder().decode(TokenCredential.self, from: encoded)

        // Then
        XCTAssertEqual(decoded.accessToken, tokenCredential.accessToken)
        XCTAssertEqual(decoded.refreshToken, tokenCredential.refreshToken)
    }
}
