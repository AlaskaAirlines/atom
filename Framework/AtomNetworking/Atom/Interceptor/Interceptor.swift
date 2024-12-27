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
import os.log

/// An object for handling task-level events & logging for `URLSession` requests.
internal final class Interceptor: NSObject, Sendable {
    /// The OSLog instance to use.
    internal let log: OSLog

    /// The Bool indicating whether logging is enabled.
    internal let isEnabled: Bool

    /// Creates a `Interceptor` instance given the provided parameter(s).
    ///
    /// - Parameters:
    ///   - log:       The service configuration data used for initializing `Service` instance.
    ///   - isEnabled: The Bool indicating whether logging is enabled.
    internal init(for log: OSLog, isEnabled: Bool) {
        self.log = log
        self.isEnabled = isEnabled
    }
}
