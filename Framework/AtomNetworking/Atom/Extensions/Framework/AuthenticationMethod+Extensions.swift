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

extension AuthenticationMethod {
    /// A computed property that provides a `HeaderItem` for the request.
    ///
    /// This property creates and returns a new `HeaderItem` instance using the specified `headerField`
    /// and `headerValue`. It ensures that each request has the correct authorization header setup
    /// based on these values.
    var authorizationHeaderItem: HeaderItem {
        .init(name: headerField, value: headerValue)
    }
}

// MARK: - Private Properties and Methods

extension AuthenticationMethod {
    /// Returns "Authorization" as the header field name.
    private var headerField: String { "Authorization" }

    /// Returns authorization value based on specified method case.
    private var headerValue: String {
        switch self {
        case let .basic(credential):
            return "Basic \(credential.combined.base64)"
        case let .bearer(_, _, writable):
            return "Bearer \(writable.tokenCredential.accessToken)"
        case .none:
            return String()
        }
    }
}
