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

import Foundation

public extension Atom {
    /// The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
    struct Response {
        public typealias HeaderFields = NSDictionary

        /// All HTTP header fields of the response.
        public let allHeaderFields: HeaderFields?

        /// The expected length of the response’s content.
        public let expectedContentLength: Int64?

        /// The data returned by the server.
        public let data: Data?

        /// The MIME type of the response.
        public let mimeType: String?

        /// The response’s HTTP status code.
        public let statusCode: Int?

        /// A suggested filename for the response data.
        public let suggestedFilename: String?

        /// The name of the text encoding provided by the response’s originating source.
        public let textEncodingName: String?

        /// The URL for the response.
        public let url: URL?
    }
}

// MARK: Convenience Initializers

internal extension Atom.Response {
    /// Creates a `Response` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - data:     The Data returned by URLSession completion.
    ///   - response: The URLresponse returned by URLSession completion.
    init(_ data: Data? = nil, _ response: URLResponse? = nil) {
        let response = response as? HTTPURLResponse

        self.allHeaderFields = response?.allHeaderFields as HeaderFields?
        self.expectedContentLength = response?.expectedContentLength
        self.data = data
        self.mimeType = response?.mimeType
        self.statusCode = response?.statusCode
        self.suggestedFilename = response?.suggestedFilename
        self.textEncodingName = response?.textEncodingName
        self.url = response?.url
    }

    /// Creates a `Response` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - statusCode: The response’s HTTP status code.
    init(statusCode: Int) {
        self.allHeaderFields = nil
        self.expectedContentLength = nil
        self.data = nil
        self.mimeType = nil
        self.statusCode = statusCode
        self.suggestedFilename = nil
        self.textEncodingName = nil
        self.url = nil
    }
}
