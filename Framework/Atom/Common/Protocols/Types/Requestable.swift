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

/// The `Requestable` protocol declares an interface used for initializing network request object.
public protocol Requestable {
    /// The array of header items to apply to a `URLRequest`.
    var headerItems: [Atom.HeaderItem]? { get }

    /// The HTTP method to apply to a `URLRequest`.
    var method: Atom.Method { get }

    /// The array of query items to apply to a URL.
    var queryItems: [Atom.QueryItem]? { get }

    /// The `Bool` indicating whether or not authorization header should be applied
    /// automatically by Atom to a `URLRequest` instance created from `Requestable`.
    var requiresAuthentication: Bool { get }

    /// The base url to initialize `URLRequest` with.
    ///
    /// The URL host must begin and end with a word.
    ///
    /// ````
    /// func baseURL() throws -> Atom.BaseURL {
    ///     try Atom.BaseURL(host: "api.alaskaair.net")
    /// }
    /// ````
    /// In the event that provided URL host fails validation, the client will be notified
    /// at the time of a network call by receiving `RequestableError.invalidBaseURL` error.
    func baseURL() throws -> Atom.BaseURL

    /// The URL path to append to a base URL.
    ///
    /// The path should begin with a forward slash `/` and end with a word.
    ///
    /// ````
    /// func path() throws -> Atom.URLPath {
    ///     try Atom.URLPath("/path/to/resource")
    /// }
    /// ````
    /// In the event when provided URL path fails validation, the client will be notified
    /// at the time of a network call by receiving `RequestableError.invalidURLPath` error.
    func path() throws -> Atom.URLPath
}
