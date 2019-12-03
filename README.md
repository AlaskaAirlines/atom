## Overview

The lightweight & delightful networking library.

Atom is a wrapper library built around a subset of features offered by `URLSession` with added ability to decode data into models, handle access token refresh and authorization headers on behalf of the client, and more. It takes advantage of Swift features such as default implementation for protocols, generics and `Decodable` to make it extremely easy to integrate and use in an existing project. Atom offers support for any endpoint, a much stricter URL host and path validation, comprehensive [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) and an example application to eliminate any guesswork.


## Features
- [x] Simple to setup, easy to use & efficient
- [x] Supports any endpoint
- [x] Handles object decoding from data returned by the service
- [x] Handles token refresh
- [x] Handles and applies authorization headers on behalf of the client
- [x] Handles URL host validation
- [x] Handles URL path validation
- [x] Complete [Documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html)


## Requirements
* iOS 11.0+
* Xcode 11.0+
* Swift 5.0+


## Installation

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate Atom into your Xcode project using Carthage, specify it in your `Cartfile`:

```
git "https://github.com/AlaskaAirlines/atom" ~> 1.0.0
```

For more information on getting started with Carthage, visit the [repo](https://github.com/Carthage/Carthage).

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Atom as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.


## Usage
Getting started is easy. First, create an instance of Atom.

```swift
let atom = Atom()
```

In the above example, default configuration will be used. Default configuration will setup `URLSession`to use ephemeral configuration as well as ensure that the data returned by the service is available on the main thread.

Any network request needs to conform and implement `Requestable` protocol. The `Requestable ` protocol provides default implementation for all of its properties - except for the `func baseURL() throws -> Atom.BaseURL`. See [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) for more information.

```swift
extension Seatmap {
    enum Endpoint: Requestable {
        case refresh

        func baseURL() throws -> Atom.BaseURL {
            try Atom.BaseURL(host: "api.alaskaair.net")
        }
    }
}
```

Atom offers a handful of methods with support for fully decoded model objects, raw data,  or status indicating success / failure of a request.

```swift
typealias Endpoint = Seatmap.Endpoint

service.load(Endpoint.refresh).execute(expecting: Seatmap.self) { [weak self] result in
    switch result {
        case .failure(let error):
        // Handle error.

        case .success(let seatmap):
        // Handle seatmap model.
    }
}
```

The above example demonstrates how to use `execute()` method to get a fully decoded `Seatmap` model object.

For more information, please see [documentation](https://htmlpreview.github.com/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html).

### Authentication

Atom can be configured to apply authorization headers on behalf of the client. 

Atom supports `Basic` and `Bearer` authentication methods. When configured properly, Atom will perform automatic token refresh on behalf of the client if it determines that the access token being used has expired. Any in-flight calls will be enqueued and executed once a new token is obtained. 

If the token refresh call fails, all enqueued network calls will be executed at once with completions set to `AtomError` failure.

### Basic

You can configure Atom to apply `Basic` authorization header like this:

```swift
let atom: Atom = {
    let credential = Atom.BasicCredential(password: "password", username: "username")
    let basic = Atom.AuthenticationMethod.basic(credential)
    let configuration = Atom.ServiceConfiguration(authenticationMethod: basic)

    return Atom(serviceConfiguration: configuration)
}()

```

An existing implementation can be extended by conforming and implementing `BasicCredentialConvertible` protocol. A hypothetical configuration can look something like this:

```swift
final class CredentialManager {
    private(set) var username = String()
    private(set) var password = String()

    static let shared = CredentialManager()
    private init() { }

    func update(username aUsername: String) {
        username = aUsername
    }

    func update(password aPassword: String) {
        password = aPassword
    }
}

extension CredentialManager: BasicCredentialConvertible {
    var basicCredential: Atom.BasicCredential {
        .init(password: password, username: username)
    }
}

let atom: Atom = {
    let basic = Atom.AuthenticationMethod.basic(CredentialManager.shared.basicCredential)
    let configuration = Atom.ServiceConfiguration(authenticationMethod: basic)

    return Atom(serviceConfiguration: configuration)
}()

```

Once configured, Atom will combine username and password into a single string `username:password`, encode the result using base 64 encoding algorithm and apply it to a request as a `Authorization: Basic TGlmZSBoYXMgYSBtZWFuaW5nLg==` header key-value.

### Bearer
You can configure Atom to apply `Bearer ` authorization header. Here is an example:

```swift
class TokenManager: TokenCredentialWritable {
    var tokenCredential: Atom.TokenCredential {
    	// Read values from the keychain.
        get { keychain.tokenCredential() }
        
        // Save new value to the keychain.  
        set { keychain.save(tokenCredential: newValue)  }
    }
}

let atom: Atom = {
    let endpoint = Atom.AuthorizationEndpoint(host: "api.alaskaair.net", path: "/oauth2")
    let clientCredential = Atom.ClientCredential(id: "client-id", secret: "client-secret")
    let tokenManager = TokenManager()

    let bearer = Atom.AuthenticationMethod.bearer(endpoint, clientCredential, tokenManager)
    let configuration = Atom.ServiceConfiguration(authenticationMethod: bearer)

    return Atom(serviceConfiguration: configuration)
}()
```

The setup is hopefully easy to understand. Atom requires a few pieces of information from the client:

1. Authorization endpoint - Atom needs to know where to call to get a new token.
2. Client credentials - Atom needs access to client id and client secret to get a new token.
3. Token credential writable - Atom will pass newly obtained credentials to a client for safe storage.

Once configured, Atom will apply authorization header to a request as `Authorization: Bearer ...` header key-value.

Please note, Atom will only decode token credential from a JSON objecting returned in this form:

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