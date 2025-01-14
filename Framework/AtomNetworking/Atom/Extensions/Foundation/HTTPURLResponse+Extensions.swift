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

import Foundation

// MARK: - Helper Properties and Methods

internal extension HTTPURLResponse {
    /// Convenience initializer for creating an `HTTPURLResponse` with just a status code.
    ///
    /// - Parameters:
    ///   - statusCode: The HTTP status code for the response.
    ///
    /// - Returns: An optional `HTTPURLResponse` instance. Returns `nil` if `URL.empty` is `nil`,
    ///   which should not happen under normal circumstances since `URL.empty` is statically defined.
    ///
    /// - Note: Uses a predefined empty URL (`URL.empty`) which defaults to "/". This initializer
    ///   omits specifying the HTTP version and header fields, setting them to `nil`.
    convenience init?(statusCode: Int) {
        guard let empty = URL.empty else {
            return nil
        }

        self.init(url: empty, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
}
