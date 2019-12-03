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
    /// Model object representing base URL composed from URL scheme and host.
    struct BaseURL {
        /// The URL scheme as defined in RFC 2718.
        internal let scheme: Atom.BaseURL.Scheme

        /// The URL host as defined in RFC 1738.
        internal let host: String

        /// Creates a `BaseURL` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - scheme: The URL scheme as defined in RFC 2718.
        ///   - host:   The URL host as defined in RFC 1738.
        ///
        /// - Throws: `RequestableError.invalidBaseURL` when URL host validation fails.
        public init(scheme: Atom.BaseURL.Scheme = .https, host: String) throws {
            guard host.isValidURLHost else {
                throw RequestableError.invalidBaseURL
            }

            self.scheme = scheme
            self.host = host
        }
    }
}

// MARK: StringConvertible

extension Atom.BaseURL: StringConvertible {
    var stringValue: String { scheme.stringValue + host }
}

extension Atom.BaseURL.Scheme: StringConvertible {
    var stringValue: String {
        switch self {
        case .http:
            return "http://"
        case .https:
            return "https://"
        }
    }
}
