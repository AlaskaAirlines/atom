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

internal extension NSRegularExpression {
    /// Returns RFC compliant regex pattern for a URL host.
    ///
    /// Once a pattern is created, unless there was a change, it will just work. A forced
    /// crash, when the `NSRegularExpression` instance creation fails, is intentional.
    static let urlHost: NSRegularExpression = {
        do {
            let pattern = "^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])(\\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$"

            return try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch { fatalError("Error initializing a valid NSRegularExpression instance given provided pattern for URL host validation. Error: \(error).") }
    }()

    /// Returns a RFC compliant regex pattern for a URL path.
    ///
    /// Once a pattern is created, unless there was a change, it will just work. A forced
    /// crash, when the `NSRegularExpression` instance creation fails, is intentional.
    static let urlPath: NSRegularExpression = {
        do {
            let pattern = "(^[/]((\\w.+)))+.(\\w)+"

            return try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch { fatalError("Error initializing a valid NSRegularExpression instance given provided pattern for URL path validation. Error: \(error).") }
    }()
}
