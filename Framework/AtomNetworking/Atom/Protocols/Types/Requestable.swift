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

// MARK: - Requestable

/// The `Requestable` protocol declares an interface used for initializing network request object.
public protocol Requestable: Sendable {
    /// The array of header items to apply to a `URLRequest`.
    var headerItems: [HeaderItem]? { get }

    /// The HTTP method to apply to a `URLRequest`.
    var method: HTTPMethod { get }

    /// The array of query items to apply to a URL.
    var queryItems: [QueryItem]? { get }

    /// The `Bool` indicating whether or not authorization header should be applied
    /// automatically by Atom to a `URLRequest` instance created from `Requestable`.
    var requiresAuthorization: Bool { get }

    /// The base url to initialize `URLRequest` with.
    ///
    /// The URL host must begin and end with a word.
    ///
    /// ```swift
    /// func baseURL() throws(AtomError) -> BaseURL {
    ///     try BaseURL(host: "api.alaskaair.net")
    /// }
    /// ````
    /// In the event that provided URL host fails validation, the client will be notified
    /// at the time of a network call by receiving `RequestableError.invalidBaseURL` error.
    func baseURL() throws(AtomError) -> BaseURL

    /// The URL path to append to a base URL.
    ///
    /// The path should begin with a forward slash `/` and end with a word.
    ///
    /// ```swift
    /// func path() throws(AtomError) -> URLPath {
    ///     try URLPath("/path/to/resource")
    /// }
    /// ````
    /// In the event when provided URL path fails validation, the client will be notified
    /// at the time of a network call by receiving `RequestableError.invalidURLPath` error.
    func path() throws(AtomError) -> URLPath
}

// MARK: - Default Implementation

/// Default implementation for `Requestable` protocol.
extension Requestable {
    /// The default value is `nil`.
    public var headerItems: [HeaderItem]? { nil }

    /// The default value is `.get`.
    public var method: HTTPMethod { .get }

    /// The default valus is `nil`.
    public var queryItems: [QueryItem]? { nil }

    /// The default valus is `true`.
    public var requiresAuthorization: Bool { true }

    /// The default valus is `URLPath.default`.
    public func path() throws(AtomError) -> URLPath { URLPath.default }
}
