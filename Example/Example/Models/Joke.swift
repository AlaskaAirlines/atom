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

import Atom
import Foundation

internal struct Joke {
    /// The id of the joke.
    internal let id: Int

    /// The joke itself, text.
    internal let joke: String

    /// The server response indicating success or a failure.
    internal let response: Joke.Response

    /// List of possible server responses.
    internal enum Response: String, Decodable {
        /// Indicates success of an API call.
        case success

        /// Indicates failure of an API call.
        case failure
    }
}

// MARK: Model

extension Joke: Model {
    /// List of top level coding keys.
    private enum CodingKeys: String, CodingKey {
        case response = "type"
        case value
    }

    /// List of nested cosing keys for `value`.
    private enum ValueKeys: String, CodingKey {
        case id
        case joke
    }

    /// Decodable conformance.
    internal init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.response = try values.decode(Response.self, forKey: .response)

        let additionalInfo = try values.nestedContainer(keyedBy: ValueKeys.self, forKey: .value)
        self.id = try additionalInfo.decode(Int.self, forKey: .id)
        self.joke = try additionalInfo.decode(String.self, forKey: .joke)
    }

    /// Encodable conformance.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ValueKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(joke, forKey: .joke)
    }
}
