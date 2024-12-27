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

internal final class AtomErrorTests: XCTestCase {
    internal func testAtomErrorReturnsExpectedStringValue() {
        // Give, When
        let decoder = "decoder"
        let requestable = "requestable"
        let response = "response"
        let session = "session"
        let unexpected = "unexpected"

        let decodingError = DecodingError.typeMismatch(Void.self, .init(codingPath: [], debugDescription: .init()))
        let requestableError = RequestableError.invalidURL
        let atomResponse = AtomResponse(statusCode: 401)

        // Then
        XCTAssertEqual(AtomError.decoder(decodingError).stringValue, decoder)
        XCTAssertEqual(AtomError.requestable(requestableError).stringValue, requestable)
        XCTAssertEqual(AtomError.response(atomResponse).stringValue, response)
        XCTAssertEqual(AtomError.session(NSError()).stringValue, session)

        XCTAssertEqual(AtomError.unexpected.stringValue, unexpected)
    }
}
