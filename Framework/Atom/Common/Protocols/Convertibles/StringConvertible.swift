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

/// The `StringConvertible` protocol declares an interface used for representing conforming type as a string.
///
/// `StringConvertible` protocol is defined and used despite having similar protocols available
/// in Standard Library (ex: `CustomStringConvertible`). This is intentional due to how these protocols
/// are defined and used. For example, documentation for `CustomStringConvertible` has this suggestion:
///
/// "Accessing a type’s description property directly or using `CustomStringConvertible` as a generic constraint is discouraged."
internal protocol StringConvertible {
    /// Returns conforming type as a **loosely** constructed string representation.
    var stringValue: String { get }
}
