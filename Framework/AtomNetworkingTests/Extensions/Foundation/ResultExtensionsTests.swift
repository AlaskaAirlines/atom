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

internal final class ResultExtensionsTests: XCTestCase {
    internal func testInitializeFailureWithError() {
        // Given
        let error = NSError(domain: "domain", code: 100, userInfo: nil)

        // When
        let result = Result<Void, NSError>(error)

        // Then
        XCTAssertNil(result.value)
        XCTAssertNotNil(result.error)
    }

    internal func testFailureUnwrapThrowsError() {
        // Given
        let result = Result<Void, AtomError>(.unexpected)

        // When
        var expectedError: Error?

        // Then
        do {
            try result.unwrap()
        } catch {
            expectedError = error
        }

        XCTAssertNotNil(expectedError)
    }

    internal func testInitializeSuccessWithValue() {
        // Given, When
        let value = "Alaska Airlines"
        let result = Result<String, NSError>(value)

        // Then
        XCTAssertNil(result.error)
        XCTAssertEqual(result.value, value)
    }

    internal func testSuccessUnwrapReturnsValue() throws {
        // Given
        let value = "Alaska Airlines"
        let result = Result<String, NSError>(value)

        // When
        let expectedValue = try result.unwrap()

        // Then
        XCTAssertEqual(expectedValue, value)
    }
}
