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

/// The metadata associated with the response to a URL load request, independent of protocol and URL scheme.
public struct AtomResponse: Sendable {
    /// The data returned by the server.
    public let data: Data

    /// The response object containing HTTP-specific details.
    public let httpResponse: HTTPURLResponse?

    /// The response’s HTTP status code.
    public var statusCode: Int? {
        httpResponse?.statusCode
    }
}
