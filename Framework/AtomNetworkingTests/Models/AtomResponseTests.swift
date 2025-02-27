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

final class AtomResponseTests: XCTestCase {
    func testInitializeWithNilValues() {
        // Given, When
        let response: AtomResponse = .init(response: nil)

        // Then
        XCTAssertNotNil(response)
    }

    func testInitializeWithDataNilResponseSuccess() {
        // Given, When
        let response: AtomResponse = .init(response: HTTPURLResponse(statusCode: 200).unwrap() as URLResponse)

        // Then
        XCTAssertNotNil(response)
        XCTAssertEqual(response.httpResponse?.statusCode, 200)
        XCTAssertEqual(response.httpResponse?.url?.absoluteString, "/")
    }

    func testInitializeWithDataURLResponseNil() {
        // Given, When
        let response: AtomResponse = .init(response: nil)

        // Then
        XCTAssertNotNil(response)
        XCTAssertNotNil(response.data)
        XCTAssertNil(response.httpResponse)
    }
}
