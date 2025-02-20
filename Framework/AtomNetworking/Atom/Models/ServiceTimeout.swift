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

/// Model object representing `URLSessionConfiguration` timeout intervals.
public struct ServiceTimeout: Sendable {
    // MARK: - Properties

    /// The timeout interval to use when waiting for additional data.
    var request: Double

    /// The maximum amount of time that a resource request should be allowed to take.
    var resource: Double

    // MARK: - Lifecycle

    /// Creates a `ServiceTimeout` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - request:  The timeout interval to use when waiting for additional data.
    ///   - resource: The maximum amount of time that a resource request should be allowed to take.
    public init(request: Double = 30.0, resource: Double = 30.0) {
        self.request = request
        self.resource = resource
    }
}
