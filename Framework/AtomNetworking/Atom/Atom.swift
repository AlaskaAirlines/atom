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

/// The lightweight & delightful networking library.
public struct Atom: Sendable {
    // MARK: - Properties

    /// The `ServiceActor` instance.
    private let serviceActor: ServiceActor

    // MARK: - Lifecycle

    /// Creates a `Atom` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The service configuration data used for initializing `Service` instance.
    public init(serviceConfiguration: ServiceConfiguration = ServiceConfiguration()) {
        self.serviceActor = ServiceActor(serviceConfiguration: serviceConfiguration)
    }

    // MARK: - Functions

    /// Enqueues a `Requestable` and returns a `Service` that will execute it.
    ///
    /// The returned `Service` captures the request and sends it to a shared
    /// internal actor that:
    ///
    /// - Executes network requests
    /// - Handles token refresh
    /// - Ensures that only one refresh happens at a time when multiple requests detect an expired token
    ///
    /// All requests share the same internal actor, so if the token is expired, concurrent callers
    /// will wait for the same refresh instead of triggering multiple refresh calls.
    ///
    /// - Parameters:
    ///   - requestable: The request to execute.
    ///
    /// - Returns: A `Service` used to start the request via `resume(...)`.
    public func enqueue(_ requestable: Requestable) -> Service {
        Service(serviceActor: serviceActor, requestable: requestable)
    }
}
