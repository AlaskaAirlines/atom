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

import Foundation
import os.log

internal extension OSLog {
    /// An identifier string, in reverse DNS notation, representing the subsystem that’s performing
    /// logging. By default, bundle identifier of the application integrating Atom will be used. In the unlikely
    /// case that the bundle identifier cannot be retrieved, `com.alaskaair.atom` will be assigned.
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.alaskaair.atom"

    /// A custom log object to use for for all authentication related logging.
    static let authentication = OSLog(subsystem: subsystem, category: "Authentication")

    /// A custom log object to use for for all model related logging.
    static let model = OSLog(subsystem: subsystem, category: "Model")

    /// A custom log object to use for for all network related logging.
    static let network = OSLog(subsystem: subsystem, category: "Network")
}
