## Overview

The lightweight & delightful networking library.

Atom is a wrapper library built around a subset of features offered by `URLSession` with added ability to decode data into models, handle access token refresh and authorization headers on behalf of the client, and more. It takes advantage of Swift features such as default implementation for protocols, generics and `Decodable` to make it extremely easy to integrate and use in an existing project. Atom offers support for any endpoint, a much stricter URL host and path validation, comprehensive [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) and an example application to eliminate any guesswork.


## Features
- [x] Simple to setup, easy to use & efficient
- [x] Supports any endpoint
- [x] Supports Combine publishers
- [x] Supports Multipath TCP configuration
- [x] Handles object decoding from data returned by the service
- [x] Handles token refresh
- [x] Handles and applies authorization headers on behalf of the client
- [x] Handles URL host validation
- [x] Handles URL path validation
- [x] Complete [Documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html)


## Requirements
* iOS 15.0+
* Xcode 16.0+
* Swift 6.0+


## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Atom as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

If you are using Xcode, adding Atom as a dependency is even easier. First, select your application, then your application project. Once you see **Swift Packages** tab at the top of the Project Editor, click on it. Click `+` button and add the following URL:

`https://github.com/alaskaairlines/atom/`

At this point you can setup your project to either use a branch or tagged version of the package.

## Usage
Getting started is easy. First, create an instance of Atom.

```swift
let atom = Atom()
```

In the above example, the default configuration will be used. This configuration sets up URLSession to use an ephemeral session and ensures that the data returned by the service is available on the main thread when calling completion-based APIs.

When using async/await APIs, Atom will return results on the same thread where `URLSession` returns data. You are empowered to use custom actors or apply the `@MainActor` attribute to a function or an entire type (e.g., `ViewModel`) to ensure operations run on the main thread.


Any endpoint needs to conform and implement `Requestable` protocol. The `Requestable ` protocol provides default implementation for all of its properties - except for the `func baseURL() throws(AtomError) -> BaseURL`. See [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) for more information.

```swift
extension Seatmap {
    enum Endpoint: Requestable {
        case refresh

        func baseURL() throws(AtomError) -> BaseURL {
            try BaseURL(host: "api.alaskaair.net")
        }
    }
}
```

Atom offers a handful of methods with support for fully decoded model objects, raw data,  or status indicating success / failure of a request.

```swift
typealias Endpoint = Seatmap.Endpoint

let seatmap = try await atom.enqueue(Endpoint.refresh).resume(expecting: Seatmap.self)

```

The above example demonstrates how to use `resume(expecting:)` function to get a fully decoded `Seatmap` model object.

For more information, please see [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html).

### Authentication

Atom can be configured to apply authorization headers on behalf of the client. It supports both `Basic` and `Bearer` authentication methods. When properly configured, Atom will automatically refresh tokens for the client if it determines that the access token has expired.

However, if the token refresh attempt fails, all subsequent network calls will fail.

### Basic

You can configure Atom to apply `Basic` authorization header like this:

```swift
let atom: Atom = {
    let credential = BasicCredential(password: "password", username: "username")
    let basic = AuthenticationMethod.basic(credential)
    let configuration = ServiceConfiguration(authenticationMethod: basic)

    return Atom(serviceConfiguration: configuration)
}()

```

An existing implementation can be extended by conforming and implementing `BasicCredentialConvertible` protocol. A hypothetical configuration can look something like this:

```swift
actor CredentialManager {
    private(set) var username = String()
    private(set) var password = String()

    static let shared = CredentialManager()
    private init() {}

    func update(username aUsername: String) {
        username = aUsername
    }

    func update(password aPassword: String) {
        password = aPassword
    }
}

extension CredentialManager: BasicCredentialConvertible {
    var basicCredential: BasicCredential {
        .init(password: password, username: username)
    }
}

let atom: Atom = {
    let basic = AuthenticationMethod.basic(CredentialManager.shared.basicCredential)
    let configuration = ServiceConfiguration(authenticationMethod: basic)

    return Atom(serviceConfiguration: configuration)
}()

```

Once configured, Atom will combine username and password into a single string `username:password`, encode the result using base 64 encoding algorithm and apply it to a request as a `Authorization: Basic TGlmZSBoYXMgYSBtZWFuaW5nLg==` header key-value.

### Bearer
You can configure Atom to apply `Bearer ` authorization header. Here is an example:

```swift
actor TokenManager: TokenCredentialWritable {
    var tokenCredential: TokenCredential {
    	// Read values from the keychain.
        get { keychain.tokenCredential() }
        
        // Save new value to the keychain.  
        set { keychain.save(tokenCredential: newValue)  }
    }
}

let atom: Atom = {
    let endpoint = AuthorizationEndpoint(host: "api.alaskaair.net", path: "/oauth2")
    let clientCredential = ClientCredential(id: "client-id", secret: "client-secret")
    let tokenManager = TokenManager()

    let bearer = AuthenticationMethod.bearer(endpoint, clientCredential, tokenManager)
    let configuration = ServiceConfiguration(authenticationMethod: bearer)

    return Atom(serviceConfiguration: configuration)
}()
```

The setup is hopefully easy to understand. Atom requires a few pieces of information from the client:

1. Authorization endpoint - Atom needs to know where to call to get a new token.
2. Client credentials - Atom needs access to client id and client secret to get a new token.
3. Token credential writable - Atom will pass newly obtained credentials to a client for safe storage.

Once configured, Atom will apply authorization header to a request as `Authorization: Bearer ...` header key-value.

**NOTE:** Please ensure that any type conforming to `TokenCredentialWritable` writes and reads keychain values in a thread-safe manner. The successful token refresh depends on being able to read the new token credential value after it has been saved to the keychain following a refresh.

Also, Atom will only decode token credential from a JSON objecting returned in this form:

```json
{
    "access_token": "2YotnFZFEjr1zCsicMWpAA",
    "expires_in": 3600,
    "refresh_token": "tGzv3JOkF0XG5Qx2TlKWIA"
}
```

The above response is in accordance with [RFC 6749, section 1.5](https://tools.ietf.org/html/rfc6749#section-1.5).

For more information and Atom usage example, please see [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) and the provided Example application.

## Communication
* If you found a bug, open an issue.
* If you have a feature request, open an issue.
* If you want to contribute, submit a pull request.

## Authors
* [Michael Babiy](https://github.com/michaelbabiy)
