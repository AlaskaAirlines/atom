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

internal extension JSONDecoder {
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - Parameters:
    ///   - type: The type of the value to decode.
    ///   - data: The data to decode from.
    ///
    /// - Returns: A value of the requested type.
    ///
    /// - Throws: An error if any value throws an error during decoding.
    func decode<T>(type: T.Type, from data: Data) throws(AtomError) -> T where T: Model {
        do {
            return try decode(type, from: data)
        } catch let error as DecodingError {
            throw .decoder(error)
        } catch {
            throw .unexpected
        }
    }
}
