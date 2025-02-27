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

import SwiftUI

struct ContentView: View {
    // MARK: - SwiftUI Properties

    /// View model for this view.
    @ObservedObject
    var vm: ContentViewModel = .init()

    // MARK: - Content Properties

    var body: some View {
        content
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $vm.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text("See debug console for details."),
                    dismissButton: .default(Text("OK"))
                )
            }
    }

    // MARK: Content

    private var content: some View {
        ZStack {
            // Set background view.
            Color.midnight

            // Basic layout.
            VStack {
                Spacer()
                Text(vm.joke.value)
                    .foregroundColor(.white)
                    .padding()

                Spacer()

                Button {
                    Task { try? await vm.random() }
                } label: {
                    Text("REFRESH")
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                .padding(.bottom, 40.0)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
