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

/// Performs an operation with a checked continuation, mapping any thrown Error to AtomError.
///
/// - Parameters:
///   - operation: A closure that takes a CheckedContinuation and performs the work.
///
/// - Returns: The continuation's success value.
/// - Throws:  AtomError (mapped from any underlying Error).
func withAtomCheckedContinuation<T>(operation: (CheckedContinuation<T, Error>) -> Void) async throws(AtomError) -> T {
    do {
        return try await withCheckedThrowingContinuation {
            operation($0)
        }
    } catch {
        throw (error as? AtomError) ?? .unexpected
    }
}
