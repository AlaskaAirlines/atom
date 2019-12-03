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

public extension Atom {
    /// Model object representing Service configuration.
    class ServiceConfiguration {
        /// The authentication method indicating how authorization header will be handled in Atom.
        internal let authenticationMethod: Atom.AuthenticationMethod

        /// The `Atom.ServiceConfiguration.Configuration` - default value is `.ephemeral`.
        internal let configuration: Atom.ServiceConfiguration.Configuration

        /// The JSONDecoder for decoding data into models.
        internal let decoder: JSONDecoder

        /// The queue to dispatch `Result` object on.
        internal let dispatchQueue: DispatchQueue

        /// The standardized timeout interval for request and resource.
        internal let timeout: Atom.ServiceConfiguration.Timeout

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

        /// Creates a `ServiceConfiguration` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - authenticationMethod: The authentication method indicating how authorization header will be handled in Atom.
        ///   - configuration:        The `Atom.ServiceConfiguration.Configuration` - default value is `.ephemeral`.
        ///   - decoder:              The `JSONDecoder` for decoding data into models.
        ///   - dispatchQueue:        The queue to dispatch `Result` object on.
        public init(authenticationMethod: Atom.AuthenticationMethod = .none, configuration: Atom.ServiceConfiguration.Configuration = .ephemeral, decoder: JSONDecoder = JSONDecoder(), dispatchQueue: DispatchQueue = .main) {
            self.authenticationMethod = authenticationMethod
            self.configuration = configuration
            self.decoder = decoder
            self.dispatchQueue = dispatchQueue
            self.timeout = Timeout()
        }
    }
}

// MARK: Configuration

internal extension Atom.ServiceConfiguration {
    /// Returns `URLSessionConfiguration` for each `Atom.ServiceConfiguration.Configuration` case.
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

        return sessionConfiguration
    }
}
