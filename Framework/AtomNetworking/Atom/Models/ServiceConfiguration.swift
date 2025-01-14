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

/// Model object representing `ServiceConfiguration` configuration.
public struct ServiceConfiguration: Sendable {
    /// The authentication method indicating how authorization header will be handled.
    internal let authenticationMethod: AuthenticationMethod

    /// The `SessionConfiguration` - default value is `.ephemeral`.
    internal let configuration: SessionConfiguration

    /// The `JSONDecoder` instance for decoding raw data into models.
    internal let decoder: JSONDecoder

    /// The queue to dispatch `Result` object on.
    internal let dispatchQueue: DispatchQueue

    /// The standardized timeout interval for request and resource.
    internal let timeout: ServiceTimeout

    /// A `Bool` indicating whether or not all service requests should be logged to the console.
    internal let isLogEnabled: Bool

    /// Constants that specify the type of service that Multipath TCP uses.
    ///
    /// The multipath service type determines whether multipath TCP should be attempted and the conditions
    /// for creating and switching between subflows. Using these service types requires the appropriate entitlement. Any
    /// connection attempt will fail if the process does not have the required entitlement.
    ///
    /// Available options are:
    ///  - `.none`        - The default service type indicating that Multipath TCP should not be used.
    ///  - `.handover`    - A Multipath TCP service that provides seamless handover between Wi-Fi and cellular in order to preserve the connection.
    ///  - `.interactive` - A service whereby Multipath TCP attempts to use the lowest-latency interface.
    ///  - `.aggregate`   - A service that aggregates the capacities of other Multipath options in an attempt to increase throughput and minimize latency.
    public typealias MultipathServiceType = URLSessionConfiguration.MultipathServiceType

    /// The service type that specifies the Multipath TCP connection policy for transmitting data over Wi-Fi and cellular interfaces.
    internal var multipathServiceType: MultipathServiceType = .none

    /// Creates a `ServiceConfiguration` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - authenticationMethod: The authentication method indicating how authorization header will be handled in Atom.
    ///   - configuration:        The `ServiceConfiguration.Configuration` - default value is `.ephemeral`.
    ///   - decoder:              The `JSONDecoder` for decoding data into models.
    ///   - dispatchQueue:        The queue to dispatch `Result` object on.
    ///   - multipathServiceType: The service type that specifies the Multipath TCP connection policy for transmitting data over Wi-Fi and cellular interfaces.
    ///   - timeout:              Timeout interval needed for URLSessionConfiguration.
    ///   - isLogEnabled:         A `Bool` indicating whether or not all service requests should be logged to the console.
    public init(
        authenticationMethod: AuthenticationMethod = .none,
        configuration: SessionConfiguration = .ephemeral,
        decoder: JSONDecoder = .init(),
        dispatchQueue: DispatchQueue = .main,
        multipathServiceType: MultipathServiceType = .none,
        timeout: ServiceTimeout = .init(),
        isLogEnabled: Bool = false)
    {
        self.authenticationMethod = authenticationMethod
        self.configuration = configuration
        self.decoder = decoder
        self.dispatchQueue = dispatchQueue
        self.multipathServiceType = multipathServiceType
        self.timeout = timeout
        self.isLogEnabled = isLogEnabled
    }
}
