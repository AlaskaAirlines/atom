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

public extension Optional {
    /// Unwraps an optional value. Terminates the process if the value is `nil`.
    ///
    /// - Warning:
    ///   While useful for eliminating the need for `if let` check for guaranteed values,
    ///   unwrapping `nil` optionals will result in a crash.
    ///
    ///
    /// - Parameters:
    ///   - because: The reason / expectation for why the value will never be `nil`.
    ///   - file:    The filename where the method is called from.
    ///   - line:    The line number where the method is called from.
    ///
    /// - Returns: Value of the expected type.
    func unwrap(_ because: (() -> String)? = nil, file: StaticString = #file, line: UInt = #line) -> Wrapped {
        if let value = self { return value }

        let message = because?() ?? "Unexpectedly found nil when unwrapping \(Wrapped.self)."

        fatalError(message, file: file, line: line)
    }
}
