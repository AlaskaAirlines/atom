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

/// Model object representing the location of the authorization server.
public struct AuthorizationEndpoint: Sendable {
    /// The base url of the authorization server.
    internal let baseURL: BaseURL

    /// The url path of the authorization server.
    internal let path: URLPath

    /// Creates a `AuthorizationEndpoint` instance given the provided parameter(s).
    ///
    /// Before an instance of the `AuthorizationEndpoint` can be created, host and path will be
    /// validated using regex patters defined in `NSRegularExpression+Additions`. If validation
    /// fails for any reason, an exception will be raised by Atom - this is intentional to ensure
    /// a valid authorization endpoint is provided during Atom configuration.
    ///
    /// - Parameters:
    ///   - host: The URL host as defined in RFC 1738.
    ///   - path: The URL path as defined in RFC 1738.
    ///
    /// - Throws: `AtomError` when initialization fails.
    public init(host: String, path: String) throws(AtomError) {
        self.baseURL = try BaseURL(host: host)
        self.path = try URLPath(path)
    }
}
