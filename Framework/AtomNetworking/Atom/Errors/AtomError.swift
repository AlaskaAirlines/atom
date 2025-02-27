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

/// List of all possible error cases thrown by `Atom` framework.
@frozen
public enum AtomError: Error, Sendable {
    /// Decoder failed to decode data.
    case decoder(DecodingError)

    /// Failed to initialize `URLRequest` with `Requestable` instance.
    case requestable(RequestableError)

    /// Service returned invalid response where the status code is not in `200...299` range.
    ///
    /// An optional response `data` will be set for further processing of the `body`. In the
    /// context of ACE Group, `data` will contain the error message or the model object.
    ///
    /// For more information, see `AtomResponse`.
    case response(AtomResponse)

    /// URLSession failed with error.
    case session(Error)

    /// Unexpected, logic error.
    case unexpected
}
