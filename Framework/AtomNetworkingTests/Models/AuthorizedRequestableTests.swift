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

internal final class AuthorizedRequestableTests: XCTestCase {
    internal func testInitializeFromRequestableMapsRequestableProperties() throws {
        // Given
        let endpoint = Endpoint()
        let method = AuthenticationMethod.basic(.init(password: "password", username: "username"))
        let expectedHeaderItems = [method.authorizationHeaderItem] + [.init(name: "name", value: "value")]
        let sortedExpectedHeaderItems = expectedHeaderItems.sorted { $0.name < $1.name }

        // When
        let authorizedRequestable = AuthorizedRequestable(requestable: endpoint, authorizationHeaderItems: [method.authorizationHeaderItem])
        let sortedActualHeaderItems = authorizedRequestable.headerItems?.sorted { $0.name < $1.name }

        // Then
        XCTAssertEqual(sortedExpectedHeaderItems, sortedActualHeaderItems)
        XCTAssertEqual(endpoint.method, authorizedRequestable.method)
        XCTAssertEqual(endpoint.queryItems, authorizedRequestable.queryItems)
        XCTAssertEqual(endpoint.requiresAuthorization, authorizedRequestable.requiresAuthorization)
        XCTAssertEqual(try endpoint.baseURL(), try  authorizedRequestable.baseURL())
        XCTAssertEqual(try endpoint.path(), try authorizedRequestable.path())
    }
}

// MARK: - Test Data

private extension AuthorizedRequestableTests {
    private struct Endpoint: Requestable {
        var headerItems: [HeaderItem]? {
            [.init(name: "name", value: "value")]
        }

        var method: HTTPMethod { .get }

        var queryItems: [QueryItem]? {
            [.init(name: "name", value: "value")]
        }

        var requiresAuthorization: Bool {
            true
        }

        func baseURL() throws(AtomError) -> BaseURL {
            try .init(host: "api.alaskaair.com")
        }

        func path() throws(AtomError) -> URLPath {
            try .init("/path")
        }
    }
}
