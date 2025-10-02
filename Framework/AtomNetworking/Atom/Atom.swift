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

    /// The `Service` instance.
    private let service: Service

    // MARK: - Lifecycle

    /// Creates a `Atom` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The service configuration data used for initializing `Service` instance.
    public init(serviceConfiguration: ServiceConfiguration = ServiceConfiguration()) {
        self.service = Service(serviceConfiguration: serviceConfiguration)
    }

    // MARK: - Functions

    /// Prepares `Service` for a network call.
    ///
    /// Calling `enqueue(_:)` method will not initiate a network call until
    /// one of the available methods on `Service` is called first.
    ///
    /// - Note:
    ///   Calling `enqueue(_:)` method multiple times without executing a network call will update
    ///   previously set `requestable` property on `Service` with new value. This framework
    ///   does not support queue based flow.
    ///
    /// - Parameters:
    ///   - requestable: The requestable item containing required data for a network call.
    ///
    /// - Returns: Updated `Service` instance initialized using `ServiceConfiguration`.
    public func enqueue(_ requestable: Requestable) -> Service {
        service.update(with: requestable)
    }
}
