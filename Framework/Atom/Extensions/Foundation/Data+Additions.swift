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

/// Conforming `Data` type to `Model` protocol allows it to be used where `Model` is expected.
extension Data: Model { }

// MARK: Internal

internal extension Data {
    /// Attempts to serialize `self` into a JSON object for debug purposes. If serialization
    /// fails, an instance of `self` is returned.
    ///
    /// This property is used in `URLRequest+Additions` for constructing debug description of
    /// the request that is about to be resumed by `URLSession`.
    var jsonObjectOrSelf: Any {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return self
        }

        return jsonObject
    }
}
