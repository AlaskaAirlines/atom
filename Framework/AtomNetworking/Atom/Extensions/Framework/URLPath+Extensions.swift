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

internal extension URLPath {
    /// Provides default implementation value for the `Requestable` protocol.
    ///
    /// For documentation see `URLPath.init` declaration.
    static let `default` = URLPath()

    /// Creates a `URLPath` instance where path is an empty string.
    ///
    /// This implementation is used by internal static constant `default` to
    /// provide default implementation for the `Requestable.path()` method.
    ///
    /// ```swift
    /// func path() throws -> URLPath {
    ///     return URLPath.default
    /// }
    /// ```
    ///
    /// This approach allows url path method implementation to remain as an optional
    /// requirement and yet when implemented by the client, validate url path where the value is
    /// guaranteed to be valid or invalid.
    private init() {
        self.path = String()
    }
}

// MARK: - Protocol Conformance

extension URLPath: StringConvertible {
    var stringValue: String { path }
}
