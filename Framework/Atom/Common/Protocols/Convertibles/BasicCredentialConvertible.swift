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

/// The `BasicCredentialConvertible` protocol declares an interface used for converting conforming type to `Atom.BasicCredential`.
///
/// Atom can be configured to automatically apply authorization header to any `Requestable` instance. Once properly configured, Atom will read
/// credentials from the storage specified by the client and apply them to `Requestable` instance if `requiresAuthentication` property
/// is set to `true`. Values will be set as `Authorization: Basic base64-encoded-credential` header value.
///
/// For more information see `Atom.Configuration` documentation.
public protocol BasicCredentialConvertible {
    /// Returns conforming type as `Atom.BasicCredential`.
    var basicCredential: Atom.BasicCredential { get }
}
