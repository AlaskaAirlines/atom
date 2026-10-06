## Overview

The lightweight & delightful networking library.

Atom is a wrapper library built around a subset of features offered by `URLSession` with added ability to decode data into models, handle access token refresh and authorization headers on behalf of the client, and more. It takes advantage of Swift features such as default implementation for protocols, generics and `Decodable` to make it extremely easy to integrate and use in an existing project. Atom offers support for any endpoint, a much stricter URL host and path validation, comprehensive [documentation](https://htmlpreview.github.io/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) and an example application to eliminate any guesswork.


## Features
- [x] Simple to setup, easy to use & efficient
- [x] Supports any endpoint
- [x] Supports Multipath TCP configuration
- [x] Handles object decoding from data returned by the service
- [x] Handles token refresh
- [x] De-duplicates identical in-flight GET requests
- [x] Serves responses from a cache you supply and own, opted in per endpoint, off by default
- [x] Supports composable plugins wrapped around request execution
- [x] Fails fast, with a typed error, when the device has no network path, once `ConnectivityPlugin` is installed
- [x] Handles and applies authorization headers on behalf of the client
- [x] Handles URL host validation
- [x] Handles URL path validation
- [x] Complete [Documentation](https://htmlpreview.github.io/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html)


## Requirements
* iOS 17.0+
* Xcode 16.0+
* Swift 6.0+


## What is new in 5.1

Atom no longer inherits a response cache. Until 5.1 Atom never set the session's cache, so every consumer silently got whichever cache their `SessionConfiguration` happened to carry. `.ephemeral`, the default, carried a private cache of 512,000 bytes. `.default` carried `URLCache.shared`, the same instance as the rest of the host app. Atom 5.1 assigns the cache you supply, and `nil` when you supply none, so responses are not cached unless you ask for them to be. Read [Response caching](#response-caching) for the new switches, and [the Atom 5.0 to 5.1 migration guide](Migrations/002-v5.0-to-v5.1.md) if you want the old behavior back.

`resume(decoding:)` returns the decoded model together with the response it came from. Purely additive. Use it when you need a response header, such as `Date` or `ETag`, as well as the model.

## Migrating to 5.0

Atom 5.0 raises the deployment target to iOS 17 and reports being offline as its own `AtomError` case. Both are breaking changes. See [the Atom 4.x to 5.0 migration guide](Migrations/001-v4-to-v5.md) for what changed and what to do about it.


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


Any endpoint needs to conform and implement `Requestable` protocol. The `Requestable ` protocol provides default implementation for all of its properties - except for the `func baseURL() throws(AtomError) -> BaseURL`. See [documentation](https://htmlpreview.github.io/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) for more information.

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

When you need a response header as well as the model, for example a `Date` or an `ETag`, use `resume(decoding:)` instead. It returns a `DecodedResponse`, which carries the decoded `model` and the `AtomResponse` it was decoded from.

```swift
let decoded = try await atom.enqueue(Endpoint.refresh).resume(decoding: Seatmap.self)

let seatmap = decoded.model
let servedAt = decoded.response.httpResponse?.value(forHTTPHeaderField: "Date")
```

Both functions decode through the same path, so a malformed payload throws `AtomError.decoder(_)` from either one, and a per-call `decoder:` argument behaves the same way. `resume(expecting:)` remains the shorter way to ask for just the model. There is a completion-based `resume(decoding:completion:)` as well.

For more information, please see [documentation](https://htmlpreview.github.io/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html).

### Request de-duplication

When several parts of your app ask for the same resource at once, Atom collapses those identical `GET` requests into a single network call. The first caller starts the request; any caller that arrives while it is still in flight waits for that same result instead of firing a second call. Every caller then receives the same response - or the same error, if it fails.

De-duplication applies to `GET` requests only. Requests using any other HTTP method always execute on their own, since combining them would not be safe.

It is on by default. To opt a specific endpoint out, set `allowsDeduplication` to `false`:

```swift
extension Seatmap {
    enum Endpoint: Requestable {
        case refresh

        func baseURL() throws(AtomError) -> BaseURL {
            try BaseURL(host: "api.alaskaair.net")
        }

        var allowsDeduplication: Bool { false }
    }
}
```

Requests are matched on their HTTP method and fully-resolved URL - including query items, but ignoring the `Authorization` header. De-duplication therefore behaves the same across every authentication method.

### Response caching

Atom only serves a cached response when **both** of these are true:

1. The app provides a `URLCache`.
2. The endpoint opts into caching.

If either is missing, the request goes to the service.

```swift
let responseCache = URLCache(
    memoryCapacity: 10_000_000,
    diskCapacity: 0,
    directory: nil
)

let configuration = ServiceConfiguration(cache: responseCache)
```

Then opt endpoints in individually:

```swift
var caching: ResponseCaching { .whileCacheFresh }
```

There are three options:

| Case | Behavior |
| --- | --- |
| `.disabled` | Always call the service. This is the default. |
| `.revalidatingWithService` | Always call the service, but reuse the stored body when the service returns `304`. |
| `.whileCacheFresh` | Use the cached response while the service says it is fresh. |

### Authenticated services

Use a memory-only cache:

```swift
diskCapacity: 0
```

`URLCache` does not safely separate responses by `Authorization` on its own, so clear the cache when the guest signs out:

```swift
responseCache.removeAllCachedResponses()
```

If the app has its own persistent store, clear that too.

### Pull to refresh

Be careful with `.whileCacheFresh`.

A user can pull to refresh and still get the cached response without the service being called.

For a forced refresh, use `.disabled` for that request or use `.revalidatingWithService` when every refresh must reach the service.

### If the app already owns freshness

If the app already persists data and decides when it is stale, avoid `.whileCacheFresh`.

The two freshness policies stack:

```text
app refresh interval + HTTP cache freshness
```

That can make displayed data older than the app intended.

Use `.revalidatingWithService` when the app needs its own maximum-age rule to hold.

For apps that already own persistence and freshness, `cache: nil` is often the simplest and safest choice.

### Plugins

A plugin wraps request execution. It receives the request and a `next` handler, and may inspect or replace the request, refuse it outright, or reclassify whatever comes back. Plugins run in the order they are listed, the first one outermost, and they run outside de-duplication and authorization, so a plugin that refuses a request never wakes a token refresh.

No plugins are installed by default. Add one to the configuration:

```swift
let atom = Atom(
    serviceConfiguration: ServiceConfiguration(plugins: [ConnectivityPlugin()])
)
```

#### Connectivity

`ConnectivityPlugin` refuses a request once the device has settled into having no usable network path. An offline app then fails in milliseconds with a typed error, instead of waiting out a transport timeout.

```swift
do {
    let seatmap = try await atom.enqueue(Endpoint.refresh).resume(expecting: Seatmap.self)
} catch .connectivity {
    presentOfflineBanner()
} catch {
    presentGenericFailure()
}
```

Two rules keep the plugin from refusing a request it should have sent.

* A path Atom cannot confidently classify always allows the call. A monitor that has not reported yet never gates.
* A path must stay unsatisfied for a settling window, three seconds by default, before anything is refused. A Wi-Fi to cellular handoff briefly reports an unsatisfied path on a perfectly healthy device. That transient runs to roughly two seconds. A window that is too long only means the first few seconds of a real outage fail at the transport, the way version 4 did. A window that is too short tells a connected user they have no network, which is the worse answer.

A satisfied path is never treated as permission. Captive portals and split tunnel VPNs report one while every request fails, so the plugin only ever acts on the reliable signal, which is the absence of a route.

The default monitor is `PathMonitor`, built on `NWPathMonitor`. It starts on the first request rather than at initialization. If your app already owns a monitor, conform it to `ConnectivityMonitoring` and pass it in, so the process does not run two:

```swift
ConnectivityPlugin(monitor: AppNetworkMonitor())
```

#### Writing your own

Conform to `AtomPlugin` and implement one function:

```swift
struct LoggingPlugin: AtomPlugin {
    func send(_ requestable: any Requestable, next: NextHandler) async throws(AtomError) -> AtomResponse {
        let started = ContinuousClock().now

        defer {
            print("\(requestable) took \(started.duration(to: ContinuousClock().now))")
        }

        return try await next(requestable)
    }
}
```

Calling `next` runs the rest of the pipeline. Returning or throwing without calling it short circuits the request.

A plugin may also answer a request itself, the way a cache would, by returning its own `AtomResponse`:

```swift
struct CachePlugin: AtomPlugin {
    func send(_ requestable: any Requestable, next: NextHandler) async throws(AtomError) -> AtomResponse {
        if let cached = cache.data(for: requestable) {
            return AtomResponse(data: cached, statusCode: 200)
        }

        return try await next(requestable)
    }
}
```

A plugin that answers a request short circuits everything below it, so de-duplication, authorization and the transport never run for that call.

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
final class TokenManager: TokenCredentialWritable {
    var tokenCredential: TokenCredential {
    	// Read values from the keychain.
        get { keychain.tokenCredential() }
        
        // Save new value to the keychain.  
        set { keychain.save(tokenCredential: newValue)  }
    }
}

func makeAtom() throws -> Atom {
    let endpoint = try AuthorizationEndpoint(host: "api.alaskaair.net", path: "/oauth2")
    let clientCredential = ClientCredential(id: "client-id", secret: "client-secret")
    let tokenManager = TokenManager()

    let bearer = AuthenticationMethod.bearer(endpoint, clientCredential, tokenManager)
    let configuration = ServiceConfiguration(authenticationMethod: bearer)

    return Atom(serviceConfiguration: configuration)
}
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

**NOTE:** In a high-throughput scenario where the client enqueues a large number of network calls, it’s best practice to adjust the token’s expiration time to account for the service timeout. If your `ServiceTimeout` is set to the default of 30 seconds, configure `TokenCredentialWritable` to subtract those 30 seconds from the token’s expiration time. This ensures every enqueued call has at least 30 seconds to complete before the token expires.

For more information and Atom usage example, please see [documentation](https://htmlpreview.github.io/?https://github.com/AlaskaAirlines/atom/blob/master/Documentation/index.html) and the provided Example application.

## Communication
* If you found a bug, open an issue.
* If you have a feature request, open an issue.
* If you want to contribute, submit a pull request.

## Authors
* [Michael Babiy](https://github.com/michaelbabiy)
