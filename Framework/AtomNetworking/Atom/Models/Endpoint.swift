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

/// Model object representing default `Endpoint` requestable used for initializing `Service` only.
internal struct Endpoint: Requestable, Sendable {
    /// Creates an empty Endpoint.
    ///
    /// Note: This will always fail as designed. This function is meant to
    /// allow for non-optional property initialization in the Service class,
    /// which is meant to be overridden by the client.
    ///
    /// - Returns: BaseURL with host as "".
    ///
    /// - Throws: `AtomError` when initialization and validation fails.
    internal func baseURL() throws(AtomError) -> BaseURL {
        try BaseURL(host: String())
    }
}
