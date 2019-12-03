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
    /// Model object representing URL path.
    struct URLPath {
        /// The URL path as defined in RFC 3986.
        private let path: String

        /// Creates a `URLPath` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - path: The URL path as defined in RFC 3986.
        ///
        /// - Throws: `RequestableError.invalidURLPath` when URL path validation fails.
        public init(_ path: String) throws {
            guard path.isValidURLPath else {
                throw RequestableError.invalidURLPath
            }

            self.path = path
        }
    }
}

// MARK: StringConvertible

extension Atom.URLPath: StringConvertible {
    var stringValue: String { path }
}

private extension Atom.URLPath {
    /// Creates a `URLPath` instance where path is an empty string.
    ///
    /// This implementation is used by internal static constant `default` to
    /// provide default implementation for the `Requestable.path()` method.
    /// ````
    /// func path() throws -> Atom.URLPath {
    ///     return Atom.URLPath.default
    /// }
    /// ````
    /// This approach allows url path method implementation to remain as an optional
    /// requirement and yet when implemented by the client, validate url path where the value is
    /// guaranteed to be valid or invalid.
    private init() {
        self.path = String()
    }
}

internal extension Atom.URLPath {
    /// Provides default implementation value for the `Requestable` protocol.
    ///
    /// For documentation see `Atom.URLPath.init` declaration.
    static let `default` = Atom.URLPath()
}
