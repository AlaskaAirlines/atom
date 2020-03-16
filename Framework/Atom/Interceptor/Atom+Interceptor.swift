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

internal extension Atom {
    /// An object for handling task-level events & logging for `URLSession` requests.
    final class Interceptor: NSObject {
        /// The OSLog instance to use
        private let log: OSLog

        /// Creates a `Interceptor` instance given the provided parameter(s).
        ///
        /// - Parameters:
        ///   - log: The service configuration data used for initializing `Atom.Service` instance.
        internal init(for log: OSLog) {
            self.log = log
        }
    }
}

// MARK: URLSessionTaskDelegate

extension Atom.Interceptor: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard consoleLog else { return }

        // Create formatted log value.
        let logValue = "\(String(reflecting: task))\(String(reflecting: metrics))"

        // os_log is unavailable in iOS 11 and below.
        guard #available(iOS 12, *) else {
            return print(logValue)
        }

        // Log task using os_log.
        os_log(.info, log: log, "%@", logValue)
    }
}
