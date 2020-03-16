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

/// The lightweight & delightful networking library.
public final class Atom {
    /// The `Atom.Service` instance.
    private let service: Atom.Service

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
    public var log: Bool = .off {
        didSet { consoleLog = log }
    }

    /// Creates a `Atom` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The service configuration data used for initializing `Atom.Service` instance.
    public init(serviceConfiguration: Atom.ServiceConfiguration = Atom.ServiceConfiguration()) {
        self.service = Atom.Service(serviceConfiguration: serviceConfiguration)
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

    /// Prepares `Atom.Service` for a network call.
    ///
    /// Calling `load()` method will not initiate a network call until
    /// one of the available methods on `Atom.Service` is called first.
    ///
    /// - Note:
    ///   Calling `load()` method multiple times without executing a network call will update
    ///   previously set `requestable` property on `Atom.Service` with new value. `Atom` framework
    ///   does not support queue based flow.
    ///
    /// - Parameters:
    ///   - requestable: The requestable item containing required data for a network call.
    ///
    /// - Returns: Updated `Atom.Service` instance initialized using `Atom.ServiceConfiguration`.
    func load(_ requestable: Requestable) -> Atom.Service {
        service.update(with: requestable)
    }
}
