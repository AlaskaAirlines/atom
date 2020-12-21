// Atom
//
// Copyright (c) 2020 Alaska Airlines
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
public final class Atom {
    /// The `Service` instance.
    private let service: Service

    /// A `Bool` indicating whether or not all service requests should be logged to the console.
    ///
    /// Setting `log` to `on` will log all requests to the Console. Because implementation is written
    /// using `os_log`, you can use the Colsole app to monitor and save network activity to a file for further
    /// debugging. You can also just use Xcode's console.
    ///
    /// If you choose to use the Console app for monitoring outgoing requests, you can use the
    /// following categories and subsystems to filter results.
    ///
    /// - Categories: Network, Authentication.
    /// - Subsystems: Your App's Bundle Identifier.
    public var log: Bool = false {
        didSet { consoleLog = log }
    }

    /// Creates a `Atom` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The service configuration data used for initializing `Service` instance.
    public init(serviceConfiguration: ServiceConfiguration = ServiceConfiguration()) {
        self.service = Service(serviceConfiguration: serviceConfiguration)
    }
}

public extension Atom {
    /// Cancels all currently running and suspended tasks.
    ///
    /// Calling `cancelAllSessionTasks()` method will not invalide `URLSession`
    /// instance nor will it empty cookies, cache or credential stores.
    ///
    /// All subsequent tasks will occur on the same TCP connection.
    func cancelAllSessionTasks() {
        service.cancelAllSessionTasks()
    }

    /// Prepares `Service` for a network call.
    ///
    /// Calling `enqueue(_:)` method will not initiate a network call until
    /// one of the available methods on `Service` is called first.
    ///
    /// - Note:
    ///   Calling `enqueue(_:)` method multiple times without executing a network call will update
    ///   previously set `requestable` property on `Service` with new value. `Atom` framework
    ///   does not support queue based flow.
    ///
    /// - Parameters:
    ///   - requestable: The requestable item containing required data for a network call.
    ///
    /// - Returns: Updated `Service` instance initialized using `ServiceConfiguration`.
    func enqueue(_ requestable: Requestable) -> Service {
        service.update(with: requestable)
    }
}
