// Atom
//
// Copyright (c) 2020 Alaska Airlines
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

internal class URLPathTests: BaseCase {
    internal func testURLPathInitializationFailure() {
        // Given, When
        let path = "path"
        let atomPath = try? URLPath(path)

        // Then
        XCTAssertNil(atomPath)
    }

    internal func testURLPathInitializationSuccess() {
        // Given
        let path = "/path"
        var atomPath: URLPath?
        var requestableError: RequestableError?

        // When
        do {
            atomPath = try URLPath(path)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertEqual(atomPath?.stringValue, path)
    }
}
