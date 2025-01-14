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

internal final class URLRequestExtensionsTests: XCTestCase {
    internal func testInitializeWithInvalidBaseURL() {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.invalidBaseURL

        // When
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    internal func testInitializeWithInvalidURLPath() {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.invalidURLPath

        // When
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    internal func testInitializeWithValidBaseURLAndPath() throws {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.validBaseURLPath

        // When
        let request: URLRequest = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertNotNil(request)
    }

    internal func testInitializeWithValidHeaderValues() throws {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.validHeaderValues

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.allHTTPHeaderFields, URLRequestExtensionsTests.headers.dictionary)
    }

    internal func testInitializeWithValidBodyData() throws {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.validHTTPBody

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.httpBody, URLRequestExtensionsTests.body)
    }

    internal func testInitializeWithValidHTTPMethodStringValue() throws {
        // Given
        let endpoint = URLRequestExtensionsTests.Endpoint.validMethod

        // When
        let request = try URLRequest(requestable: endpoint)

        // Then
        XCTAssertEqual(request.httpMethod, HTTPMethod.get.stringValue)
    }
}

// MARK: - Test Data

private extension URLRequestExtensionsTests {
    /// Test header values.
    private static let headers = [HeaderItem(name: "name", value: "value")]

    /// Test body data.
    private static let body = Data()

    /// List of test endpoints.
    private enum Endpoint: Requestable {
        case invalidBaseURL
        case invalidURLPath

        case validBaseURLPath
        case validHeaderValues
        case validHTTPBody
        case validMethod

        var headerItems: [HeaderItem]? { URLRequestExtensionsTests.headers }

        var method: HTTPMethod {
            switch self {
            case .validHTTPBody:
                return .post(URLRequestExtensionsTests.body)
            default:
                return .get
            }
        }

        func baseURL() throws(AtomError) -> BaseURL {
            switch self {
            case .invalidBaseURL:
                return try BaseURL(host: "/alaskaair/")
            default:
                return try BaseURL(host: "api.alaskaair.net")
            }
        }

        func path() throws(AtomError) -> URLPath {
            switch self {
            case .invalidURLPath:
                return try URLPath("path")
            default:
                return try URLPath("/path/to/resource")
            }
        }
    }
}
