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

/// The `TokenCredentialWritable` protocol declares an interface used for reading from / writing to `Atom.TokenCredential`.
///
/// Atom can be configured to automatically apply authorization header to any `Requestable` instance. Once properly configured, Atom will read
/// credentials from the storage specified by the client and apply them to `Requestable` instance if `requiresAuthentication` property
/// is set to `true`. Values will be set as `Authorization: Bearer token-credential` header value.
///
/// Proper configuration requires that the client conform and implement `TokenCredentialWritable` protocol where the conforming type is a class.
///
/// ```
/// class SSOCredential: TokenCredentialWritable {
///     var tokenCredential: Atom.TokenCredential {
///         get { keychain.value() }
///         set { keychain.save(newValue) }
///     }
/// }
/// ```
///
/// For more information see `Atom.Configuration` documentation.
public protocol TokenCredentialWritable: class {
    /// Returns conforming type as `Atom.TokenCredential`.
    var tokenCredential: Atom.TokenCredential { get set }
}
