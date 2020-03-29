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
    /// `Service` is a public facing class responsible for managing
    /// `URLSession` configuration, network calls, and decoding instances of a
    ///  data type into internal models.
    ///
    /// `Service` is available through the `Atom` instance only and cannot be
    /// initialized dirrectly. This behavior is intentional to allow for better separation
    /// of responsibilities such as creating a request, network call, and data decoding.
    class Service {
        /// The `AuthenticationManager` instance.
        private lazy var authenticationManager: Atom.AuthenticationManager = {
            Atom.AuthenticationManager(serviceConfiguration.authenticationMethod, delegate: self)
        }()

        /// The service configuration data.
        private let serviceConfiguration: Atom.ServiceConfiguration

        /// The `URLSession` instance configured from `Atom.ServiceConfiguration`.
        private let session: URLSession

        /// The requestable item to initialize `URLRequest` with.
        private var requestable: Requestable

        /// An array of retryables.
        private var retryables: [Retryable]

        /// Creates a `Service` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - serviceConfiguration: The service configuration data.
        internal init(serviceConfiguration: Atom.ServiceConfiguration) {
            self.requestable = Atom.Endpoint()
            self.retryables = [Retryable]()
            self.serviceConfiguration = serviceConfiguration
            self.session = URLSession(configuration: serviceConfiguration.sessionConfiguration, delegate: Interceptor(for: .network), delegateQueue: .main)
        }
    }
}

internal extension Atom.Service {
    /// For documentation see `Atom.cancelAllSessionTasks` declaration.
    func cancelAllSessionTasks() {
        session.getAllTasks {
            $0.forEach { $0.cancel() }
        }
    }

    /// Update requestable instance property with new data.
    func update(with requestable: Requestable) -> Atom.Service {
        self.requestable = requestable

        return self
    }
}

public extension Atom.Service {
    /// Creates and executes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you expect data returned by the
    /// service and require that data to be decoded into internal representations - models.
    ///
    /// Network request and decoding will be performed on a background thread after
    /// which the client will be notified of a `result` on a queue `Atom` was configured to use.
    ///
    /// A typical usage pattern for this method could look like this:
    /// ````
    /// atom.load(endpoint).execute(expecting: User.self) { result in
    ///     switch result {
    ///         case .failure(let error):
    ///         // Handle `AtomError`.
    ///
    ///         case .success(let user):
    ///         // Handle decoded `User` instance.
    ///     }
    /// }
    /// ````
    /// In the above example, data will be decoded into a `User` instance.
    ///
    /// - Parameters:
    ///   - type:       The type to decode.
    ///   - completion: The completion containing `Result` where the associated value is either an `AtomError` or decoded model instance.
    func execute<T>(expecting type: T.Type, completion: @escaping (Result<T, AtomError>) -> Void) where T: Model {
        // Get decoder from `ServiceConfiguration`.
        let decoder = serviceConfiguration.decoder

        // Get dispatch queue from `ServiceConfiguration`.
        let queue = serviceConfiguration.dispatchQueue

        do {
            // Initialize `URLRequest` with requestable instance.
            let request = try URLRequest(requestable: requestable)

            // Initialize `Retryable` with `URLRequest` instance and completion.
            let retryable = Atom.Retryable(request: request, requiresAuthorization: requestable.requiresAuthentication) { data, response, error in
                // Process error returned by the service.
                if let error = error {
                    queue.async { completion(Result(AtomError.session(error))) }
                }

                // Process error response returned by the service.
                else if response?.isFailure == true {
                    queue.async { completion(Result(AtomError.response(Atom.Response(data, response)))) }
                }

                // Process data returned by the service.
                else if let data = data {
                    // Check for expected type. Data conforms to `Model` and is supported return type.
                    if let value = data as? T {
                        // Initialize a result instance on the background queue.
                        let result = Result<T, AtomError>(value)

                        // Call completion on the queue `Atom.Service` was configured to use.
                        queue.async { completion(result) }
                    }

                    // Client expects fully decoded instance.
                    else {
                        do {
                            // Decode model object from data on the background queue.
                            let value = try decoder.decode(T.self, from: data)

                            // Initialize a result instance on the background queue.
                            let result = Result<T, AtomError>(value)

                            // Call completion on the queue `Atom.Service` was configured to use.
                            queue.async { completion(result) }

                        } catch {
                            // Notify the client of the decoding error returned by `JSONDecoder`.
                            queue.async { completion(Result(AtomError.decoder(error))) }
                        }
                    }
                }

                // Neither error, response nor data returned. Notify the client of the `unknown` error.
                else { queue.async { completion(Result(AtomError.unknown)) } }
            }

            // Execute retryable.
            execute(retryable)

        } catch let error as RequestableError {
            // Error initializing `URLRequest` from requestable instance.
            queue.async { completion(Result(AtomError.requestable(error))) }

        } catch {
            // Unexpected, logical error occured.
            queue.async { completion(Result(AtomError.unexpected)) }
        }
    }

    /// Creates and executes `URLRequest` initialized from `Requestable`.
    ///
    /// Use this method to make network requests where you don't expect any data returned
    /// and are only interested in knowing if the network call succeeded or failed.
    ///
    /// `Atom` framework uses a convenience computed variable on `URLResponse` - `isSuccessful`
    /// to determine success or a failure of a response based on a status code returned by the service.
    ///
    /// A typical usage pattern for this method after getting a `result` could look like this:
    /// ````
    /// atom.load(endpoint).execute { result in
    ///     switch result {
    ///         case .failure(let error):
    ///         // Handle `AtomError`.
    ///
    ///         case .success(let response):
    ///         // Handle `URLResponse`.
    ///         }
    ///     }
    /// }
    /// ````
    ///
    /// - Parameters:
    ///   - completion: The completion containing `Result` where the associated value is either an `AtomError` or `URLResponse`.
    func execute(_ completion: @escaping (Result<Atom.Response, AtomError>) -> Void) {
        // Get dispatch queue from `ServiceConfiguration`.
        let queue = serviceConfiguration.dispatchQueue

        do {
            // Initialize `URLRequest` with requestable instance.
            let request = try URLRequest(requestable: requestable)

             // Initialize `Retryable` with `URLRequest` instance and completion.
            let retryable = Atom.Retryable(request: request, requiresAuthorization: requestable.requiresAuthentication) { data, response, error in
                // Process error returned by the service.
                if let error = error {
                    queue.async { completion(Result(AtomError.session(error))) }
                }

                // Process response returned by the service.
                else if response?.isSuccessful == true {
                    // Initialize `success` case with response object.
                    queue.async { completion(Result(Atom.Response(data, response))) }
                }

                // Service returned invalid response (based on `statusCode`). Initialize `failure` case with response and optional `data` object.
                else { queue.async {
                    completion(Result(AtomError.response(Atom.Response(data, response)))) }
                }
            }

            // Execute retryable.
            execute(retryable)

        } catch let error as RequestableError {
            // Error initializing `URLRequest` from requestable instance.
            queue.async { completion(Result(AtomError.requestable(error))) }

        } catch {
            // Unexpected, logical error occured.
            queue.async { completion(Result(AtomError.unexpected)) }
        }
    }
}

// MARK: Private Implementation

private extension Atom.Service {
    func execute(_ retryable: Atom.Retryable) {
        let queue = serviceConfiguration.dispatchQueue
        let status = authenticationManager.applyAuthorizationHeader(to: retryable, on: queue)

        switch status {
        case .applied(let retryable),
             .na(let retryable):
            session.dataTask(with: retryable.request, completionHandler: retryable.completion).resume()

        case .refreshingAccessToken:
            retryables.append(retryable)
        }
    }
}

// MARK: AuthenticationManagerDelegate

extension Atom.Service: AuthenticationManagerDelegate {
    func authenticationManagerDidRefreshAccessToken() {
        for retryable in retryables {
            // Execute retryable.
            execute(retryable)

            // Remove executed retryable.
            retryables.removeFirst()
        }
    }

    func authenticationManagerDidFailToRefreshAccessTokenWithError(_ error: AtomError) {
        // Notify observers of a failed token refresh.
        center.post(name: Atom.didFailToRefreshAccessToken, object: nil, userInfo: ["error": error])

        // Complete, with error, all requests after token refresh failure.
        for retryable in retryables {
            // Notify the client of errors for each request that required authorization - token refresh failed.
            retryable.completion(nil, nil, error)

            // Remove executed retryable.
            retryables.removeFirst()
        }
    }
}
