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

// MARK: - RequestableQueueManager

/// A manager for serializing and processing a FIFO queue of asynchronous tasks.
///
/// This class uses a serial `DispatchQueue` for thread-safe mutations to shared state (`pendingTasks`, `isProcessing`), ensuring no data races. Tasks are enqueued
/// synchronously (non-blocking for callers beyond brief sync), processed asynchronously in a detached `Task` for background execution, and drained serially with `await`
/// to maintain FIFO order. An on-demand timer provides a "nudge" to recover from potential stalls (e.g., if the processor Task fails to reset due to errors or
/// suspension).
///
/// `@unchecked Sendable` is used as the queue protects state for cross-concurrency safety.
final class RequestableQueueManager: @unchecked Sendable {
    // MARK: - Properties

    /// A flag indicating if the processing loop is active. Mutated only within the serialized queue context to prevent races.
    private var isProcessing: Bool

    /// An array of pending async tasks (closures), appended in FIFO order and drained serially.
    private var pendingTasks: [() async -> Void]

    /// A serial dispatch queue for synchronizing access.
    private let queue: DispatchQueue

    /// An optional timer for periodic checks to nudge draining if the queue stalls (e.g., due to unhandled Task issues). Started on-demand and
    /// stopped when idle to minimize battery impact.
    private var checkTimer: DispatchSourceTimer?

    // MARK: - Lifecycle

    /// Initializes the queue manager with empty state.
    init() {
        self.isProcessing = false
        self.pendingTasks = .init()
        self.queue = .init(label: "com.alaskaair.atom.requestable.queue.manager")
    }

    /// Cleans up the timer on deallocation to prevent leaks or continued firing.
    deinit {
        checkTimer?.cancel()
    }

    // MARK: - Functions

    /// Enqueues a task for FIFO processing (callable synchronously from non-actors).
    ///
    /// Appends the task atomically via `queue.sync` and spawns a detached processor if not already processing. Starts the
    /// timer on-demand if the queue was empty before appending, to handle potential stalls.
    ///
    /// - Parameters:
    ///   - task: The async closure to enqueue (e.g., network operations).
    func enqueue(_ task: @escaping @Sendable () async -> Void) {
        queue.sync {
            let wasEmpty = pendingTasks.isEmpty

            pendingTasks.append(task)

            if !isProcessing {
                isProcessing = true

                Task.detached { [weak self] in
                    await self?.processQueue()
                }
            }

            if wasEmpty {
                startCheckTimer()
            }
        }
    }
}

// MARK: - Private Properties and Methods

extension RequestableQueueManager {
    /// Processes the queue asynchronously, draining tasks in FIFO order.
    ///
    /// Runs in a detached Task, awaiting each task serially to maintain order. Resets `isProcessing` after
    /// draining and stops the timer if the queue is now empty.
    private func processQueue() async {
        while let nextTask = dequeue() {
            await nextTask()
        }

        queue.sync {
            isProcessing = false

            if pendingTasks.isEmpty {
                stopCheckTimer()
            }
        }
    }

    /// Safely dequeues the first task, or nil if empty.
    ///
    /// Uses `queue.sync` for atomic access, ensuring no races in Swift 6.
    ///
    /// - Returns: The next task closure, or nil if the queue is empty.
    private func dequeue() -> (() async -> Void)? {
        queue.sync {
            pendingTasks.isEmpty ? nil : pendingTasks.removeFirst()
        }
    }

    /// Starts the on-demand timer for periodic queue checks.
    ///
    /// Creates a DispatchSourceTimer on a background queue for power efficiency,
    /// scheduling checks every 1 second. Uses leeway to allow iOS to optimize timing.
    private func startCheckTimer() {
        guard checkTimer == nil else {
            return
        }

        let timer: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: .global(qos: .background))
        timer.schedule(deadline: .now(), repeating: .milliseconds(1000), leeway: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            self?.checkAndDrainIfNeeded()
        }

        timer.resume()

        checkTimer = timer
    }

    /// Stops and clears the timer to prevent unnecessary firing when the queue is idle.
    private func stopCheckTimer() {
        checkTimer?.cancel()
        checkTimer = nil
    }

    /// Checks if tasks are pending and not processing, then spawns a processor if needed.
    ///
    /// Called periodically by the timer to recover from potential stalls (e.g., if a previous processor Task failed to reset the flag).
    private func checkAndDrainIfNeeded() {
        queue.sync {
            if !pendingTasks.isEmpty, !isProcessing {
                isProcessing = true

                Task.detached { [weak self] in
                    await self?.processQueue()
                }
            }
        }
    }
}
