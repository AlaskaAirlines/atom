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

Atom 5.1 changes one behavior for every consumer and adds two pieces of API. No public API changes shape, so nothing you have written stops compiling.

**Atom no longer inherits a response cache.** Until 5.1 Atom never set the session's cache, so every consumer silently got whichever cache their `SessionConfiguration` happened to carry. `.ephemeral`, the default, carried a private cache of 512,000 bytes. `.default` carried `URLCache.shared`, the same instance as the rest of the host app. Atom 5.1 assigns the cache you supply, and `nil` when you supply none, so responses are not cached unless you ask for them to be. Read [Response caching](#response-caching) for the new switches, and [the Atom 5.0 to 5.1 migration guide](Migrations/002-v5.0-to-v5.1.md) if you want the old behavior back.

**`resume(decoding:)` returns the decoded model together with the response it came from.** Purely additive. Reach for it when you need a response header, such as `Date` or `ETag`, as well as the model.

**`DecodedResponse` is the type it returns**, carrying `model` and `response`.


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

Atom can answer a request from a stored response instead of calling the service. Two switches control that, and a response comes from storage only when both are on.

1. **Storage.** You build a `URLCache` and hand it to the configuration. Atom assigns it to the session and does nothing else with it. Supply nothing and there is no caching at all.
2. **Authority.** Each endpoint declares whether it may be served from that cache. An endpoint that has not opted in always reaches the service, whatever headers the service returns.

The second switch is what makes the first one safe. With storage alone, installing a cache hands every endpoint the client serves to whatever the service decides to send, including headers added long after you shipped.

**What Atom did before 5.1.** Atom never set the session's cache, so the behavior came from whichever `SessionConfiguration` you picked, and nothing in the name said so:

| `SessionConfiguration` | The cache it carried |
| --- | --- |
| `.ephemeral`, the default | a private `URLCache` of 512,000 bytes in memory |
| `.default` | `URLCache.shared`, the same instance as the rest of the host app |
| `.background` | none |

Atom now assigns whatever you supply, and `nil` when you supply nothing. `nil` is not a partial opt out. It is the whole thing off, on every session configuration. See [the Atom 5.0 to 5.1 migration guide](Migrations/002-v5.0-to-v5.1.md).

#### Supplying a cache

```swift
let responseCache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 0, directory: nil)

let atom = Atom(
    serviceConfiguration: ServiceConfiguration(cache: responseCache)
)
```

Hold on to that reference. Atom keeps no handle to the cache and offers no way to clear it, so clearing is a call on the object you built. The sign out obligation below depends on that, and it is the reason the parameter takes a `URLCache` rather than a description of one.

Size it with room to spare. A single response larger than roughly a twentieth of `memoryCapacity` is not cached at all, so a 10,000,000 byte cache stores responses up to about 500,000 bytes and silently skips anything above that.

#### Opting an endpoint in

Nothing is served from the cache until an endpoint asks for it. Set `caching`:

```swift
extension Seatmap {
    enum Endpoint: Requestable {
        case refresh

        func baseURL() throws(AtomError) -> BaseURL {
            try BaseURL(host: "api.alaskaair.net")
        }

        var caching: ResponseCaching { .whileCacheFresh }
    }
}
```

There are three cases.

| Case | What it does | Choose it when |
| --- | --- | --- |
| `.disabled` | Always calls the service and never reads the cache. The default. | you have not thought about this endpoint, or its data must never come from storage |
| `.revalidatingWithService` | Always calls the service, asking whether the stored copy is still good. When the service answers `304 Not Modified`, the stored body is returned and no body crosses the network. | staleness is unacceptable and failing when offline is acceptable |
| `.whileCacheFresh` | Reads the stored copy for as long as the cache judges it fresh, and calls the service only once it does not. | you know the service's freshness headers for this endpoint, and you want reads to work offline |

**`.revalidatingWithService` fails offline exactly where `.disabled` already fails.** With no network it throws rather than falling back to the copy sitting in the cache. Read beside `.whileCacheFresh` that looks like a drawback. Read beside the default it is not, because `.disabled` fails in the same two ways, on a refused connection and on a stalled one. `.revalidatingWithService` is the default with the body bytes removed when nothing changed. For an endpoint that must never show stale data, it is a straight improvement over not caching at all.

**Why the default is `.disabled` when `allowsDeduplication` defaults to `true`.** The two point the same direction even though they look opposite. Collapsing two identical calls that are in flight at the same moment cannot hand a caller stale data, so that one is safe on. A cache can, so this one is safe off. Both defaults land where somebody who has not thought about an endpoint cannot be surprised by it.

#### Turning it off without shipping a build

`caching` is a computed property on a type you own, and Atom reads it fresh on every call. Nothing is remembered between the endpoint and the request Atom builds from it, so the property can read a remote feature flag:

```swift
var caching: ResponseCaching { FeatureFlags.responseCachingEnabled ? .whileCacheFresh : .disabled }
```

A flag flipped remotely takes effect on the next call, with no restart and no rebuilt client. Flipping it stops reads and does not evict anything, so the second step of an incident response is `responseCache.removeAllCachedResponses()`. The storage switch is not a lever here, because `cache:` is fixed when the client is built.

The same property answers pull to refresh, which is the most likely way `.whileCacheFresh` reaches production and then gets reverted. A user initiated refresh is answered from the cache like any other call. The guest pulls down, the spinner turns, the same data comes back, and nothing reports that the service was never asked. Let the endpoint know why it is being called:

```swift
struct FlightStatusEndpoint: Requestable {
    let id: String
    let isUserInitiated: Bool

    var caching: ResponseCaching {
        isUserInitiated ? .disabled : .whileCacheFresh
    }

    func baseURL() throws(AtomError) -> BaseURL {
        try BaseURL(host: "api.alaskaair.net")
    }
}
```

The forced call also refreshes the stored copy, so the next background read starts from the new response rather than the old one. `.revalidatingWithService` needs none of this, since every call under it already reaches the service.

#### Memory, disk, and signing out

**`URLCache` does not vary on the `Authorization` header, and no configuration changes that.** Two calls to one URL with two different bearer tokens produce one call to the service, and the second caller receives the first caller's body. Atom cannot fix this from where it stands.

**Clearing the cache when a guest signs out is your obligation, not Atom's.** Atom will not reach into an object the app owns:

```swift
responseCache.removeAllCachedResponses()
```

Clearing is best effort rather than a guarantee. `URLCache` has no concept of a reserved entry and there is an acknowledged race in the API, so it cannot be made airtight from outside. Where the service can help, `Vary: Authorization` on the response is the stronger fix, because it stops the two callers sharing an entry in the first place while still allowing the response to be cached.

**For an authenticated service, use a memory only cache.** Pass `diskCapacity: 0`. A memory only cache writes nothing to disk and does not survive the process, so a missed `removeAllCachedResponses()` leaks for one run of the app rather than until somebody deletes it. That matters more than it first looks, for the reason in the next section.

If your app also keeps a store of its own holding the same responses, that is a second copy of the same guest data, on disk by default, surviving the app kill that empties a memory only `URLCache`. Sign out has to clear both. Atom owns neither.

#### What this does not protect you from

Three things stay true once an endpoint is opted in.

**Duration under `.whileCacheFresh` is the service's call, not yours.** If the service sends `max-age=86400` where you assumed sixty seconds, you get a day. If it sends no freshness headers at all but does send `Last-Modified`, the cache invents a window of roughly a tenth of the document's age, which for an old document is a long time. That is why the case is picked per endpoint, with the service's headers in hand, and why `.revalidatingWithService` exists.

**A caller cannot tell a response from the cache apart from a response from the service.** The status code, the headers and the errors are the same either way. On an opted in endpoint, stale data in the app and stale data at the service look identical from the call site.

**Opting an endpoint out stops it being read from the cache. It does not stop it being written there.** `.disabled` is a bypass on the read path rather than a barrier on the write path. Every response the client fetches is stored if the service made it cacheable, whatever the endpoint declared. Three things follow:

1. The sign out obligation above covers the whole cache, not only the endpoints you opted in.
2. Memory only is the standing advice for any authenticated service rather than a nicety. It is the only thing keeping an unserved stored response off the disk.
3. **Supplying a cache and opting nothing in is worse than supplying no cache at all.** It stores and it serves nothing. "Install it now and opt endpoints in later" is the natural reading of a two switch design, and it is the wrong move.

#### If your app keeps its own store

An app that persists responses itself, and refreshes them on its own schedule, has a second cache on the far side of Atom from `URLCache`. The two do not choose between each other. They add. Only your code can start a call, and `URLCache` can only answer a call that was started, so the worst case age of what a guest sees is your refresh interval plus the service's freshness window.

**So an app that promises a hard maximum age must not opt its endpoints in to `.whileCacheFresh`.** The staleness check fires on time, the call goes out on time, the stored copy is still inside the service's `max-age`, and the cache answers without reaching the service. Every step behaves correctly and the bound is gone, with nothing at the call site revealing it. Use `.revalidatingWithService` where the bound has to hold, because every call under it reaches the service.

It also gets quietly worse the more the service cooperates. The day a service starts sending `max-age`, or starts sending a `Last-Modified`, the bound widens in response to a change nobody in your app made or saw.

`cache: nil` is a legitimate and often correct answer for such an app. It has the least to gain from a second cache and the same amount to lose.

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
