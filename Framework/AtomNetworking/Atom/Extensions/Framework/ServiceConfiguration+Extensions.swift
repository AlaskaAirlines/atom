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

// MARK: - Helper Properties and Methods

extension ServiceConfiguration {
    /// Returns `URLSessionConfiguration` for each `SessionConfiguration` case.
    var sessionConfiguration: URLSessionConfiguration {
        let sessionConfiguration: URLSessionConfiguration

        switch configuration {
        case let .background(identifier):
            sessionConfiguration = .background(withIdentifier: identifier)
        case .ephemeral:
            sessionConfiguration = .ephemeral
        case .default:
            sessionConfiguration = .default
        }

        sessionConfiguration.timeoutIntervalForRequest = timeout.request
        sessionConfiguration.timeoutIntervalForResource = timeout.resource
        sessionConfiguration.multipathServiceType = multipathServiceType

        return sessionConfiguration
    }
}
