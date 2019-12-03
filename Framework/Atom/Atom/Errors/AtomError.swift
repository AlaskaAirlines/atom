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

import Foundation

/// List of all possible error cases thrown by `Atom` framework.
public enum AtomError: Error {
    /// Decoder failed to decode data.
    case decoder(Error)

    /// Failed to initialize Data instance from `URL`.
    case data(Error)

    /// Failed to initialize `URLRequest` with `Requestable` instance.
    case requestable(RequestableError)

    /// Service returned invalid response where the status code is not in `200...299` range.
    ///
    /// An optional response `data` will be set for further processing of the `body`. In the
    /// context of ACE Group, `data` will contain the error message or the model object.
    ///
    /// For more information, see `Atom.Response`.
    case response(Atom.Response)

    /// URLSession failed with error.
    case session(Error)

    /// Unexpected, logic error.
    case unexpected

    /// Unknown error occurred.
    ///
    /// As an example, this error is thrown when `URLSession` call fails without
    /// providing any meaningful data (ex: error, response, and data are `nil`).
    case unknown
}
