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

internal class URLRequestTests: BaseCase {
    internal func testURLRequestInitializationWithInvalidBaseURL() {
        // Given, When
        let endpoint = URLRequestTests.Endpoint.invalidBaseURL
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    internal func testURLRequestInitializationWithInvalidURLPath() {
        // Given, When
        let endpoint = URLRequestTests.Endpoint.invalidURLPath
        let request = try? URLRequest(requestable: endpoint)

        // Then
        XCTAssertNil(request)
    }

    internal func testURLRequestInitializationWithValidBaseURLAndPath() {
        // Given
        let endpoint = URLRequestTests.Endpoint.validBaseURLPath
        var request: URLRequest?
        var requestableError: RequestableError?

        // When
        do {
            request = try URLRequest(requestable: endpoint)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertNotNil(request)
    }

    internal func testURLRequestInitializationWithValidHeaderValues() {
        // Given
        let endpoint = URLRequestTests.Endpoint.validHeaderValues
        var request: URLRequest?
        var requestableError: RequestableError?

        // When
        do {
            request = try URLRequest(requestable: endpoint)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertEqual(request?.allHTTPHeaderFields, URLRequestTests.headers.dictionary)
    }

    internal func testURLRequestInitializationWithValidBodyData() {
        // Given
        let endpoint = URLRequestTests.Endpoint.validHTTPBody
        var request: URLRequest?
        var requestableError: RequestableError?

        // When
        do {
            request = try URLRequest(requestable: endpoint)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertEqual(request?.httpBody, URLRequestTests.body)
    }

    internal func testURLRequestInitializationWithValidHTTPMethodStringValue() {
        // Given
        let endpoint = URLRequestTests.Endpoint.validMethod
        var request: URLRequest?
        var requestableError: RequestableError?

        // When
        do {
            request = try URLRequest(requestable: endpoint)
        } catch let error as RequestableError {
            requestableError = error
        } catch { XCTFail("Unexpected error thrown.") }

        // Then
        XCTAssertNil(requestableError)
        XCTAssertEqual(request?.httpMethod, Atom.Method.get.stringValue)
    }
}

// MARK: Test Data

private extension URLRequestTests {
    /// Test header values.
    private static let headers = [Atom.HeaderItem(name: "name", value: "value")]

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

        var headerItems: [Atom.HeaderItem]? { URLRequestTests.headers }

        var method: Atom.Method {
            switch self {
            case .validHTTPBody:
                return .post(URLRequestTests.body)
            default:
                return .get
            }
        }

        func baseURL() throws -> Atom.BaseURL {
            switch self {
            case .invalidBaseURL:
                return try Atom.BaseURL(host: "/alaskaair/")
            default:
                return try Atom.BaseURL(host: "api.alaskaair.net")
            }
        }

        func path() throws -> Atom.URLPath {
            switch self {
            case .invalidURLPath:
                return try Atom.URLPath("path")
            default:
                return try Atom.URLPath("/path/to/resource")
            }
        }
    }
}
