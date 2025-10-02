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

extension Task where Failure == Error {
    /// Awaits the task's value and maps any thrown Error to AtomError.
    ///
    /// Use this to convert generic Task throws to typed `AtomError` with custom mapping.
    ///
    /// - Returns: The Success value.
    /// - Throws: AtomError (mapped from the original Error).
    func typedValue() async throws(AtomError) -> Success {
        do {
            return try await value
        } catch {
            throw (error as? AtomError) ?? .unexpected
        }
    }
}
