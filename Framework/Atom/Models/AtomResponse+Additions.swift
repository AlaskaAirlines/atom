// Atom
//
// Copyright (c) 2020 Alaska Airlines
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

public extension AtomResponse {
    /// Returns `true` if the status code of the `AtomResponse` is not in `200...299` range.
    var isFailure: Bool { !isSuccessful }

    /// Returns `true` if the status code of the `AtomResponse` is in `200...299` range.
    var isSuccessful: Bool {
        guard let statusCode = statusCode else { return false }

        switch statusCode {
        case 200...299:
            return true
        default:
            return false
        }
    }
}
