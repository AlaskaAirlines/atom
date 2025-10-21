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

// MARK: - SessionActor

/// `SessionActor` is a type responsible for managing `URLSession` configuration, network calls, and decoding instances of a data type into internal models.
actor SessionActor: Sendable {
    // MARK: - Properties

    /// The service configuration data.
    let serviceConfiguration: ServiceConfiguration

    /// The `JSONDecoder` instance for decoding token credential.
    let credentialDecoder: JSONDecoder

    /// A flag indicating if a token refresh is currently in progress.
    var isRefreshing: Bool = false

    /// An optional Task handling the asynchronous token refresh operation.
    var refreshTask: Task<TokenCredential, Error>? = nil

    /// The `URLSession` instance configured from `ServiceConfiguration`.
    let session: URLSession

    /// The requestable item to initialize `URLRequest` with.
    private var requestable: Requestable

    // MARK: - Lifecycle

    /// Creates a `SessionActor` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The service configuration data.
    init(serviceConfiguration: ServiceConfiguration) {
        self.requestable = Endpoint()
        self.serviceConfiguration = serviceConfiguration
        self.credentialDecoder = JSONDecoder()
        self.session = URLSession(
            configuration: serviceConfiguration.sessionConfiguration,
            delegate: Interceptor(for: .network, isEnabled: serviceConfiguration.isLogEnabled),
            delegateQueue: nil
        )
    }

    // MARK: - Functions

    /// Creates and resumes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you expect data returned by the
    /// service and require that data to be decoded into internal representations - models.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///
    /// - Throws: `AtomError` instance if an error occurred.
    ///
    /// - Returns: Decoded `Model` instance.
    func resume<T>(expecting type: T.Type) async throws(AtomError) -> T where T: Model {
        let authorizedRequestable = try await applyAuthorizationHeader(to: requestable)
        let response = try await session.data(for: authorizedRequestable)

        // Atom supports returning raw data without decoding.
        guard let value = response.data as? T else {
            return try serviceConfiguration.decoder.decode(type: type, from: response.data)
        }

        return value
    }

    /// Creates and resumes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you don't expect any data returned
    /// and are only interested in knowing if the network call succeeded or failed.
    ///
    /// `Atom` framework uses a convenience computed variable on `AtomResponse` - `isSuccessful`
    /// to determine success or a failure of a response based on a status code returned by the service.
    ///
    /// - Throws: `AtomError` instance if an error occurred.
    ///
    /// - Returns: `AtomResponse` instance.
    func resume() async throws(AtomError) -> AtomResponse {
        let authorizedRequestable = try await applyAuthorizationHeader(to: requestable)

        return try await session.data(for: authorizedRequestable)
    }

    /// Update requestable instance property with new data.
    @discardableResult
    func update(with requestable: Requestable) async -> SessionActor {
        self.requestable = requestable

        return self
    }

    /// Determines whether the access token should be refreshed based on the service configuration.
    ///
    /// This asynchronous function checks the authentication method in the service configuration. It only proceeds if the method is a
    /// bearer token with a writable component.
    ///
    /// - Returns: A `Bool` value indicating if the access token needs refreshing. Returns `true` if refresh is required; otherwise, `false`.
    func needsSerialization() async -> Bool {
        guard case let .bearer(_, _, writable) = serviceConfiguration.authenticationMethod else {
            return false
        }

        return writable.tokenCredential.requiresRefresh || isRefreshing
    }
}
