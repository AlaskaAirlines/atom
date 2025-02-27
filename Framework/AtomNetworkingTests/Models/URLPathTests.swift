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

final class URLPathTests: XCTestCase {
    func testInitializeWithInvalidPath() {
        // Given, When
        let pathString = "path"
        let path = try? URLPath(pathString)

        // Then
        XCTAssertNil(path)
    }

    func testInitializeWithValidPath() {
        // Given
        let pathString = "/path"

        // When
        let path = try? URLPath(pathString)

        // Then
        XCTAssertNotNil(path)
        XCTAssertEqual(path?.stringValue, pathString)
    }
}
