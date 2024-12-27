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

/// A model structure that wraps a `Requestable` to potentially add headers or manage authorization.
///
/// This structure is useful when you need to modify or extend the behavior of an existing `Requestable`
/// without changing its underlying implementation. It can add or override headers and manage authorization flags.
internal struct AuthorizedRequestable: Sendable {
    /// The original `Requestable` object which this structure wraps.
    internal let requestable: Requestable

    /// An array of `HeaderItem` objects to be included with the request.
    internal let authorizationHeaderItems: [HeaderItem]

    /// Creates the `AuthorizedRequestable` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - requestable:              The original `Requestable` object which this structure wraps.
    ///   - authorizationHeaderItems: An array of `HeaderItem` objects to be included with the request.
    internal init(requestable: Requestable, authorizationHeaderItems: [HeaderItem]) {
        self.requestable = requestable
        self.authorizationHeaderItems = authorizationHeaderItems
    }
}
