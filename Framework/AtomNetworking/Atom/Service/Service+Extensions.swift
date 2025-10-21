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

extension Service {
    /// Executes or enqueues an asynchronous task based on whether the access token requires refreshing.
    ///
    /// This function creates a task to check if the session's access token needs to be refreshed using `sessionActor.shouldRefreshAccessToken()`. If a
    /// refresh is required, the provided task is enqueued in the `requestableQueueManager` for later execution. If no refresh is needed, the task is
    /// executed immediately within the detached task context.
    ///
    /// This mechanism ensures that tasks dependent on a valid access token are properly sequenced without blocking the caller.
    ///
    /// - Parameter task: An escaping, sendable asynchronous closure that performs the desired operation. The closure takes no parameters and returns `Void`.
    func awaitOrEnqueue(_ task: @escaping @Sendable () async -> Void) {
        Task {
            if await sessionActor.needsSerialization() {
                requestableQueueManager.enqueue(task)
            } else {
                await task()
            }
        }
    }
}
