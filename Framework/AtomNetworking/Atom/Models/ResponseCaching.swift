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

/// The caching behavior for a request, applied against the cache supplied to `ServiceConfiguration`.
///
/// Has no effect when no cache was supplied.
public enum ResponseCaching: Equatable, Sendable {
    /// Never serve this request from the cache. The default.
    case disabled

    /// Ask the service on every call, and use the stored response when it returns `304 Not Modified`.
    case revalidatingWithService

    /// Use the stored response while the cache considers it fresh. Freshness comes from the service's cache headers.
    ///
    /// - Important: The service controls how long data can remain fresh. Use `revalidatingWithService` if
    /// the caller needs to verify with the service.
    case whileCacheFresh
}
