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

/// List of supported session configurations.
///
/// Configuration enum is a reflection of available options offered by Foundation as class properties
/// on `URLSessionConfiguration`. The main reason for this abstraction is testability - see `ServiceConfigurationTests`.
public enum SessionConfiguration: Equatable, Sendable {
    /// The background session configuration is suitable for transferring data files while the app runs in the background.
    case background(String)

    /// The default session configuration that uses a persistent disk-based cache.
    case `default`

    /// Ephemeral configuration doesn’t store caches, credential stores, or any session-related data on disk (RAM only).
    case ephemeral
}
