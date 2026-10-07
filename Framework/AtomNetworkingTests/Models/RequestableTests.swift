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

// MARK: - RequestableTests

final class RequestableTests: XCTestCase {
    func testRequestableProvidesExpectedDefaultImplementation() {
        // Given, When
        let endpoint: Endpoint = .init()

        // Then
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(try? endpoint.path().stringValue, URLPath.default.stringValue)
        XCTAssertNil(endpoint.headerItems)
        XCTAssertNil(endpoint.queryItems)
    }

    func testAConformanceDeclaringNoOptionalMembersInheritsCachingDisabled() {
        // Given, When
        let endpoint: MinimalRequestable = .init()

        // Then
        XCTAssertTrue(endpoint.allowsDeduplication)

        guard case .disabled = endpoint.caching else {
            return XCTFail("A requestable declaring no caching member must inherit `.disabled`.")
        }
    }
}

// MARK: - MinimalRequestable

/// A conformance declaring none of the optional `Requestable` members, standing in for a consumer
/// endpoint written before any of them existed.
private struct MinimalRequestable: Requestable {
    func baseURL() throws(AtomError) -> BaseURL {
        try .init(host: "api.alaskaair.com")
    }

    func path() throws(AtomError) -> URLPath {
        try .init("/path")
    }
}
