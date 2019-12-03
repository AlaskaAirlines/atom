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

internal extension Result {
    /// Creates a `Result` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - failure: The error to initialize failure case with.
    init(_ failure: Failure) {
        self = .failure(failure)
    }

    /// Creates a `Result` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - success: The value to initialize success case with.
    init(_ success: Success) {
        self = .success(success)
    }
}

internal extension Result {
    /// Returns an optional error if the `Result` is Failure.
    var error: Failure? {
        guard case .failure(let error) = self else { return nil }

        return error
    }

    /// Returns an optional value if the `Result` is Success.
    var value: Success? {
        guard case .success(let value) = self else { return nil }

        return value
    }

    /// Returns an optional value if the `Result` is Success. Throws on error.
    func unwrap() throws -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
