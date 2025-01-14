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

import AtomNetworking
import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    /// The joke to display on successful fetch.
    @Published var joke: Joke = .default

    /// A boolean indicating whether an error alert should be shown.
    @Published var showError: Bool = false

    /// Fetches a random joke.
    func random() async throws {
        do {
            joke = try await atom.enqueue(JokeEndpoint.random).resume(expecting: Joke.self)
        } catch {
            // Print the error to the debug console.
            print(error)
            showError = true
        }
    }
}
