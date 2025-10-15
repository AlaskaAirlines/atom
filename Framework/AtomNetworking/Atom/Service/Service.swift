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

// MARK: - Service

/// A wrapper class for managing service operations with serialized task queuing.
///
/// This class delegates queue management to `RequestableQueueManager` for FIFO serialization of operations and interacts with `SessionActor` for session-related tasks
/// (e.g., updates). It's marked `@unchecked Sendable` for cross-concurrency safety, as the queue manager protects shared state.
public final class Service: @unchecked Sendable {
    // MARK: - Properties

    /// The manager for handling FIFO queuing and serial processing of tasks, ensuring thread-safety and order.
    let requestableQueueManager: RequestableQueueManager

    /// The actor responsible for session operations, such as updates and network calls, providing isolated state management.
    let sessionActor: SessionActor

    /// The configuration for the underlying session actor.
    let serviceConfiguration: ServiceConfiguration

    // MARK: - Lifecycle

    /// Initializes the service with a configuration.
    ///
    /// Creates a new queue manager for task serialization and a session actor for handling operations.
    ///
    /// - Parameters:
    ///   - serviceConfiguration: The configuration for the underlying session actor.
    init(serviceConfiguration: ServiceConfiguration) {
        self.requestableQueueManager = RequestableQueueManager()
        self.sessionActor = SessionActor(serviceConfiguration: serviceConfiguration)
        self.serviceConfiguration = serviceConfiguration
    }

    // MARK: - Functions

    /// Enqueues an update operation with a requestable object, returning self for chaining.
    ///
    /// This method adds the update task to the queue manager for FIFO processing and returns immediately, allowing fluent chaining (e.g., `update(...).resume(...)`). The
    /// actual update on the session actor happens asynchronously.
    ///
    /// - Parameters:
    ///   - requestable: The `Requestable` object to update the session with.
    ///
    /// - Returns: The service instance for method chaining.
    public func update(with requestable: Requestable) -> Service {
        requestableQueueManager.enqueue { [weak self] in
            guard let self else {
                return
            }

            await sessionActor.update(with: requestable)
        }

        return self
    }
}
