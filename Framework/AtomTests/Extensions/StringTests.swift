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

@testable import Atom
import XCTest

internal class StringTests: BaseCase {
    internal func testInvalidURLHost() {
        // Given, When
        let alaska = "/api.alaskaair.net"
        let apple = "apple/"
        let google = "developer*"
        let localhost = "http:localhost"
        let nike = ".com"

        // Then
        XCTAssertFalse(alaska.isValidURLHost)
        XCTAssertFalse(apple.isValidURLHost)
        XCTAssertFalse(google.isValidURLHost)
        XCTAssertFalse(localhost.isValidURLHost)
        XCTAssertFalse(nike.isValidURLHost)
    }

    internal func testValidURLHost() {
        // Given, When
        let alaska = "api.alaskaair.net"
        let apple = "apple.com"
        let google = "developer.google.io"
        let localhost = "localhost"
        let nike = "nike.nike"

        // Then
        XCTAssertTrue(alaska.isValidURLHost)
        XCTAssertTrue(apple.isValidURLHost)
        XCTAssertTrue(google.isValidURLHost)
        XCTAssertTrue(localhost.isValidURLHost)
        XCTAssertTrue(nike.isValidURLHost)
    }

    internal func testInvalidURLPath() {
        // Given, When
        let single = "path"
        let multiple = "/v1/new/path/"
        let dash = "/v2/new-path-"
        let underscore = "_/v3/new_path"

        // Then
        XCTAssertFalse(single.isValidURLPath)
        XCTAssertFalse(multiple.isValidURLPath)
        XCTAssertFalse(dash.isValidURLPath)
        XCTAssertFalse(underscore.isValidURLPath)
    }

    internal func testValidURLPath() {
        // Given, When
        let single = "/path"
        let multiple = "/v1/new/path"
        let dash = "/v2/new-path"
        let underscore = "/v3/new_path"

        // Then
        XCTAssertTrue(single.isValidURLPath)
        XCTAssertTrue(multiple.isValidURLPath)
        XCTAssertTrue(dash.isValidURLPath)
        XCTAssertTrue(underscore.isValidURLPath)
    }
}
