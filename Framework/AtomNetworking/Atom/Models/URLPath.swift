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

/// Model object representing URL path.
public struct URLPath: Sendable, Equatable {
    // MARK: - Properties

    /// The URL path as defined in RFC 3986.
    let path: String

    // MARK: - Lifecycle

    /// Creates a `URLPath` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - path: The URL path as defined in RFC 3986.
    ///
    /// - Throws: `AtomError` when URL path validation fails.
    public init(_ path: String) throws(AtomError) {
        guard path.isValidURLPath else {
            throw .requestable(.invalidURLPath)
        }

        self.path = path
    }
}
