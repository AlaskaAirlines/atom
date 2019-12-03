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

internal class ResponseTests: BaseCase {
    internal func testResponseInitializationWithNilValuesSuccess() {
        // Given, When
        let response = Atom.Response(nil, nil)

        // Then
        XCTAssertNotNil(response)
        XCTAssertNil(response.allHeaderFields)
        XCTAssertNil(response.expectedContentLength)
        XCTAssertNil(response.data)
        XCTAssertNil(response.mimeType)
        XCTAssertNil(response.statusCode)
        XCTAssertNil(response.suggestedFilename)
        XCTAssertNil(response.textEncodingName)
        XCTAssertNil(response.url)
    }

    internal func testResponseInitializationWithDataNilValueSuccess() {
        // Given
        var response: Atom.Response?
        let expectation = self.expectation(description: "Expecting URLResponse.")

        // When
        URLSession.shared.dataTask(with: url) { _, res, _ in
            response = Atom.Response(nil, res)
            expectation.fulfill()
        }.resume()

        // Then
        waitForExpectations(timeout: timeout) { _ in
            XCTAssertNotNil(response)
        }
    }

    internal func testResponseInitializationWithURLResponseNilValueSuccess() {
        // Given, When
        let response = Atom.Response(Data(), nil)

        // Then
        XCTAssertNotNil(response)
        XCTAssertNil(response.allHeaderFields)
        XCTAssertNil(response.expectedContentLength)
        XCTAssertNotNil(response.data)
        XCTAssertNil(response.mimeType)
        XCTAssertNil(response.statusCode)
        XCTAssertNil(response.suggestedFilename)
        XCTAssertNil(response.textEncodingName)
        XCTAssertNil(response.url)
    }
}

// MARK: Test Data

private extension ResponseTests {
    private var url: URL {
        guard let url = URL(string: "https://www.alaskaair.com") else {
            fatalError("Initializing URL instance with a valid URL string should never fail.")
        }

        return url
    }
}
