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
import Foundation

// MARK: - URLRequestEndpoint

/// List of test endpoints.
enum URLRequestEndpoint: Requestable {
    case invalidBaseURL
    case invalidURLPath

    case cachingDisabled
    case cachingRevalidatingWithService
    case cachingWhileCacheFresh

    case validBaseURLPath
    case validHeaderValues
    case validHTTPBody
    case validMethod

    // MARK: - Static Properties

    /// Test body data.
    static let body: Data = .init()

    /// Test header values.
    static let headers = [HeaderItem(name: "name", value: "value")]

    // MARK: - Computed Properties

    var caching: ResponseCaching {
        switch self {
        case .cachingRevalidatingWithService:
            return .revalidatingWithService
        case .cachingWhileCacheFresh:
            return .whileCacheFresh
        default:
            return .disabled
        }
    }

    var headerItems: [HeaderItem]? { URLRequestEndpoint.headers }

    var method: HTTPMethod {
        switch self {
        case .validHTTPBody:
            return .post(URLRequestEndpoint.body)
        default:
            return .get
        }
    }

    // MARK: - Functions

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
