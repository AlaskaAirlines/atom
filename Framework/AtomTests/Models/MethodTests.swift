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

internal class MethodTests: BaseCase {
    internal func testMethodCaseReturnsExpectedStringValue() {
        // Give, When
        let delete = "DELETE"
        let get = "GET"
        let patch = "PATCH"
        let post = "POST"
        let put = "PUT"

        // Then
        XCTAssertEqual(Atom.Method.delete.stringValue, delete)
        XCTAssertEqual(Atom.Method.get.stringValue, get)
        XCTAssertEqual(Atom.Method.patch(Data()).stringValue, patch)
        XCTAssertEqual(Atom.Method.post(Data()).stringValue, post)
        XCTAssertEqual(Atom.Method.put(Data()).stringValue, put)
    }
}
