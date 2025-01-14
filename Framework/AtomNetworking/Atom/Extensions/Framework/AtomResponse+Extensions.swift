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

public extension AtomResponse {
    /// Returns default, success response where status code is 200.
    static let success = AtomResponse(statusCode: 200)

    /// Returns `true` if the status code of the `AtomResponse` is not in `200...299` range.
    var isFailure: Bool { !isSuccess }

    /// Returns `true` if the status code of the `AtomResponse` is in `200...299` range.
    var isSuccess: Bool {
        guard let statusCode = statusCode else { return false }

        return (200...299).contains(statusCode)
    }

    /// Creates a `AtomResponse` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - data:     The Data returned by URLSession completion.
    ///   - response: The URLresponse returned by URLSession completion.
    internal init(data: Data = .init(), response: URLResponse? = nil) {
        self.data = data
        self.httpResponse = response as? HTTPURLResponse
    }

    /// Creates a `AtomResponse` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - statusCode: The response’s HTTP status code.
    internal init(statusCode: Int) {
        self.data = .init()
        self.httpResponse = .init(statusCode: statusCode)
    }
}
