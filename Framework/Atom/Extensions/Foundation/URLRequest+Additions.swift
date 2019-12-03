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

internal extension URLRequest {
    /// Creates a `URLRequest` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - requestable: The `Requesatble` item containing all required data to initialize `self`.
    init(requestable: Requestable) throws {
        // Validate base URL, get a string value if validation succeeds.
        let baseURLString = try requestable.baseURL().stringValue

        // Validate URL path, get a string value if validation succeeds.
        let pathString = try requestable.path().stringValue

        // Add query parameters, if any.
        guard let url = URLComponents(baseURLString, path: pathString, queryItems: requestable.queryItems)?.url else {
            throw RequestableError.invalidURL
        }

        // Initialize `self`.
        self.init(url: url)

        // Set additional values.
        allHTTPHeaderFields = requestable.headerItems?.dictionary
        httpBody = requestable.method.body
        httpMethod = requestable.method.stringValue
    }
}
