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

import AtomNetworking
import Foundation

/// The response cache handed to AtomNetworking.
///
/// Memory only, `diskCapacity: 0`, which is the recommendation for any authenticated service. Opting an endpoint
/// out stops Atom reading its responses from the cache but does not stop them being written there, so a disk-backed
/// cache would hold responses from endpoints nobody opted in.
///
/// Holding this reference here is the point of the example rather than the sizing. Atom keeps no handle to the
/// cache and offers no way to clear it, so clearing at sign out is a one-line call on this object:
///
/// responseCache.removeAllCachedResponses()
let responseCache: URLCache = .init(memoryCapacity: 10_000_000, diskCapacity: 0, directory: nil)

/// Global instance of AtomNetworking library.
let atom: Atom = {
    let method: AuthenticationMethod = .basic(BasicCredential(password: "password", username: "username"))

    let configuration: ServiceConfiguration = .init(
        authenticationMethod: method,
        cache: responseCache,
        plugins: [ConnectivityPlugin()],
        isLogEnabled: true
    )

    return .init(serviceConfiguration: configuration)
}()
