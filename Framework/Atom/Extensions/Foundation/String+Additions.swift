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

internal extension String {
    /// Returns `self` as Base64 encoded string.
    var base64: String {
        Data(utf8).base64EncodedString()
    }

    /// Returns `NSRange` instance for the entire length of `self` starting at the beginning.
    var lengthRange: NSRange {
        NSRange(location: 0, length: count)
    }

    /// Returns boolean value indicating whether `self` is a valid URL host.
    ///
    /// Validation is done using `NSRegularExpression` pattern declared in `NSRegularExpression+Additions`.
    var isValidURLHost: Bool {
        guard let match = NSRegularExpression.urlHost.firstMatch(in: self, options: .anchored, range: lengthRange) else {
            return false
        }

        return NSEqualRanges(match.range, lengthRange)
    }

    /// Returns boolean value indicating whether `self` is a valid URL path.
    ///
    /// Validation is done using `NSRegularExpression` pattern declared in `NSRegularExpression+Additions`.
    var isValidURLPath: Bool {
        guard let match = NSRegularExpression.urlPath.firstMatch(in: self, options: .anchored, range: lengthRange) else {
            return false
        }

        return NSEqualRanges(match.range, lengthRange)
    }
}
