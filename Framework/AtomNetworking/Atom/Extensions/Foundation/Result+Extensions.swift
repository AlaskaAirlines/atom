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

import Foundation

// MARK: - Helper Properties and Methods

extension Result {
    /// Returns an optional error if the `Result` is Failure.
    var error: Failure? {
        guard case let .failure(error) = self else {
            return nil
        }

        return error
    }

    /// Returns an optional value if the `Result` is Success.
    var value: Success? {
        guard case let .success(value) = self else {
            return nil
        }

        return value
    }

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

    /// Returns an optional value if the `Result` is Success. Throws on error.
    func unwrap() throws -> Success? {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}
