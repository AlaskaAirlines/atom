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

internal class BaseURLTests: BaseCase {
    internal func testBaseURLInitializationFailure() {
        // Given
        let host = ".api.alaskaair.net"
        let atomBaseURL = try? BaseURL(host: host)

        // Then
        XCTAssertNil(atomBaseURL)
    }

    internal func testBaseURLInitializationSuccess() {
        // Given
        let host = "api.alaskaair.net"
        let baseURL = "https://api.alaskaair.net"
        var atomBaseURL: BaseURL?
        var requestableError: RequestableError?

        // When
        do {
            atomBaseURL = try BaseURL(host: host)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertEqual(atomBaseURL?.stringValue, baseURL)
    }
}
