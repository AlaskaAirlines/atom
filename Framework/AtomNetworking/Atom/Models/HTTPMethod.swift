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

/// List of primary HTTP methods.
public enum HTTPMethod: Equatable, Sendable {
    /// Use for deleting a resource identified by a URI.
    case delete

    /// Use for reading (or retrieving) a representation of a resource.
    case get

    /// Use for modifying capabilities.
    case patch(Data)

    /// Use for creating new resources.
    case post(Data)

    /// Use for replacing a resource.
    case put(Data)
}
