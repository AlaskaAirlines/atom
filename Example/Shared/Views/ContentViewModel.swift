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

import Atom
import Combine
import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    /// The joke to display on successful fetch.
    @Published var joke: Joke = .default

    /// Fetches a random joke.
    func random() async throws {
        do {
            joke = try await atom
                .enqueue(Joke.Endpoint.random)
                .resume(expecting: Joke.self)
        } catch { joke = .default }
    }
}
