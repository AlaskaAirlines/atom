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

// MARK: - URLRequestExtensionsTests

final class URLRequestExtensionsTests: XCTestCase {
    func testInitializeWithInvalidBaseURL() {
        // Given
        let endpoint: URLRequestEndpoint = .invalidBaseURL

        // When
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    func testInitializeWithInvalidURLPath() {
        // Given
        let endpoint: URLRequestEndpoint = .invalidURLPath

        // When
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    func testInitializeWithValidBaseURLAndPath() throws {
        // Given
        let endpoint: URLRequestEndpoint = .validBaseURLPath

        // When
        let request: URLRequest = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertNotNil(request)
    }

    func testInitializeWithValidHeaderValues() throws {
        // Given
        let endpoint: URLRequestEndpoint = .validHeaderValues

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.allHTTPHeaderFields, URLRequestEndpoint.headers.dictionary)
    }

    func testInitializeWithValidBodyData() throws {
        // Given
        let endpoint: URLRequestEndpoint = .validHTTPBody

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.httpBody, URLRequestEndpoint.body)
    }

    func testInitializeWithValidHTTPMethodStringValue() throws {
        // Given
        let endpoint: URLRequestEndpoint = .validMethod

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.stringValue)
    }

    func testEveryResponseCachingCaseStampsItsOwnCachePolicyOnTheRequest() throws {
        // Given, When
        let disabled: URLRequest = try .init(requestable: URLRequestEndpoint.cachingDisabled)
        let revalidating: URLRequest = try .init(requestable: URLRequestEndpoint.cachingRevalidatingWithService)
        let whileCacheFresh: URLRequest = try .init(requestable: URLRequestEndpoint.cachingWhileCacheFresh)

        // Then
        XCTAssertEqual(disabled.cachePolicy, .reloadIgnoringLocalCacheData)
        XCTAssertEqual(revalidating.cachePolicy, .reloadRevalidatingCacheData)
        XCTAssertEqual(whileCacheFresh.cachePolicy, .useProtocolCachePolicy)
    }

    func testARequestableThatSaysNothingAboutCachingIsStampedToIgnoreTheLocalCache() throws {
        // Given
        let endpoint: TransportEndpoint = .init()

        // When
        let request: URLRequest = try .init(requestable: endpoint)

        // Then
        XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData)
    }
}
