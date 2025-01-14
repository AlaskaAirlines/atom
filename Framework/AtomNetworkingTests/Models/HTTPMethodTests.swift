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

internal final class HTTPMethodTests: XCTestCase {
    internal func testHTTPMethodReturnsExpectedStringValue() {
        // Give, When
        let delete = "DELETE"
        let get = "GET"
        let patch = "PATCH"
        let post = "POST"
        let put = "PUT"

        // Then
        XCTAssertEqual(HTTPMethod.delete.stringValue, delete)
        XCTAssertEqual(HTTPMethod.get.stringValue, get)
        XCTAssertEqual(HTTPMethod.patch(.init()).stringValue, patch)
        XCTAssertEqual(HTTPMethod.post(.init()).stringValue, post)
        XCTAssertEqual(HTTPMethod.put(.init()).stringValue, put)
    }
}
