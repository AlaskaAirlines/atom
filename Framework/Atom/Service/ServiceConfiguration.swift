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

/// Model object representing Service configuration.
public final class ServiceConfiguration {
    /// The authentication method indicating how authorization header will be handled in
    internal let authenticationMethod: AuthenticationMethod

    /// The `ServiceConfiguration.Configuration` - default value is `.ephemeral`.
    internal let configuration: ServiceConfiguration.Configuration

    /// The JSONDecoder for decoding data into models.
    internal let decoder: JSONDecoder

    /// The queue to dispatch `Result` object on.
    internal let dispatchQueue: DispatchQueue

    /// The standardized timeout interval for request and resource.
    internal let timeout: ServiceConfiguration.Timeout

    /// List of supported session configurations.
    ///
    /// Configuration enum is a reflection of available options offered
    /// by Foundation as class properties on `URLSessionConfiguration`. The
    /// main reason for this abstraction is testability - see `ServiceConfigurationTests`.
    public enum Configuration: Equatable {
        /// The background session configuration is suitable for transferring data files while the app runs in the background.
        case background(String)

        /// The default session configuration that uses a persistent disk-based cache.
        case `default`

        /// Ephemeral configuration doesn’t store caches, credential stores, or any session-related data on disk (RAM only).
        case ephemeral
    }

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
    #if os(iOS)
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
    public init(authenticationMethod: AuthenticationMethod = .none, configuration: Configuration = .ephemeral, decoder: JSONDecoder = JSONDecoder(), dispatchQueue: DispatchQueue = .main, multipathServiceType: MultipathServiceType = .none) {
        self.authenticationMethod = authenticationMethod
        self.configuration = configuration
        self.decoder = decoder
        self.dispatchQueue = dispatchQueue
        self.multipathServiceType = multipathServiceType
        self.timeout = Timeout()
    }

    #else

    /// Creates a `ServiceConfiguration` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - authenticationMethod: The authentication method indicating how authorization header will be handled in Atom.
    ///   - configuration:        The `ServiceConfiguration.Configuration` - default value is `.ephemeral`.
    ///   - decoder:              The `JSONDecoder` for decoding data into models.
    ///   - dispatchQueue:        The queue to dispatch `Result` object on.
    public init(authenticationMethod: AuthenticationMethod = .none, configuration: Configuration = .ephemeral, decoder: JSONDecoder = JSONDecoder(), dispatchQueue: DispatchQueue = .main) {
        self.authenticationMethod = authenticationMethod
        self.configuration = configuration
        self.decoder = decoder
        self.dispatchQueue = dispatchQueue
        self.timeout = Timeout()
    }
    #endif
}

// MARK: Configuration

internal extension ServiceConfiguration {
    /// Returns `URLSessionConfiguration` for each `ServiceConfiguration.Configuration` case.
    var sessionConfiguration: URLSessionConfiguration {
        let sessionConfiguration: URLSessionConfiguration

        switch configuration {
        case .background(let identifier):
            sessionConfiguration = .background(withIdentifier: identifier)
        case .ephemeral:
            sessionConfiguration = .ephemeral
        case .default:
            sessionConfiguration = .default
        }

        sessionConfiguration.timeoutIntervalForRequest = timeout.request
        sessionConfiguration.timeoutIntervalForResource = timeout.resource

        #if os(iOS)
        sessionConfiguration.multipathServiceType = multipathServiceType
        #endif

        return sessionConfiguration
    }
}
