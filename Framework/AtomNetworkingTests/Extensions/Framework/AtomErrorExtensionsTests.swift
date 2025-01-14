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

internal final class AtomErrorExtensionsTests: XCTestCase {
    internal func testIsAuthorizationFailure() {
        // Given, When
        let error = AtomError.response(AtomResponse(statusCode: 401))

        // Then
        XCTAssertTrue(error.isAuthorizationFailure)
    }

    internal func testIsAccessTokenRefreshFailure() {
        // Given, When
        let error = AtomError.session(AtomError.response(AtomResponse(statusCode: 400)))

        // Then
        XCTAssertTrue(error.isAccessTokenRefreshFailure)
    }

    internal func testDataDecodeIfPresentErrorData() throws {
        // Given
        let json = ["key": "value"]
        let data = try JSONEncoder().encode(json)
        let error = AtomError.response(AtomResponse(data: data, response: nil))

        // When
        let dictionary = try error.decodeIfPresent(as: [String: String].self)

        // Then
        XCTAssertNotNil(dictionary)
        XCTAssertEqual(dictionary?["key"], "value")
    }
}
