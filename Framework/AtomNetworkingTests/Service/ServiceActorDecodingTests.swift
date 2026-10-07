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

@testable import AtomNetworking
import Foundation
import XCTest

// MARK: - ServiceActorDecodingTests

final class ServiceActorDecodingTests: XCTestCase {
    func testDecodingReturnsTheSameModelAsExpectingAndTheResponseItWasDecodedFrom() async throws {
        // Given
        let body: Data = .init("{\"value\":\"atom\"}".utf8)

        StubURLProtocol.arm(with: .success(statusCode: 200, data: body))

        let serviceConfiguration: ServiceConfiguration = .init()
        let serviceActor: ServiceActor = .init(serviceConfiguration: serviceConfiguration, session: StubURLProtocol.session)

        // When
        let decoded: DecodedResponse<Payload> = try await serviceActor.resume(for: TransportEndpoint(), decoding: Payload.self)
        let expected: Payload = try await serviceActor.resume(for: TransportEndpoint(), expecting: Payload.self)

        // Then
        XCTAssertEqual(decoded.model, expected)
        XCTAssertEqual(decoded.model.value, "atom")
        XCTAssertEqual(decoded.response.data, body)
        XCTAssertEqual(decoded.response.statusCode, 200)
        XCTAssertEqual(decoded.response.httpResponse?.statusCode, 200)
        XCTAssertEqual(decoded.response.httpResponse?.url?.absoluteString, "https://api.alaskaair.com/path")
    }

    func testAMalformedPayloadSurfacesAsADecoderErrorFromBothEntryPoints() async {
        // Given
        let body: Data = .init("{\"unexpected\":\"atom\"}".utf8)

        StubURLProtocol.arm(with: .success(statusCode: 200, data: body))

        let serviceConfiguration: ServiceConfiguration = .init()
        let serviceActor: ServiceActor = .init(serviceConfiguration: serviceConfiguration, session: StubURLProtocol.session)

        // When
        var decodingError: AtomError?
        var expectingError: AtomError?
        var underlyingDecodingError: DecodingError?

        do {
            _ = try await serviceActor.resume(for: TransportEndpoint(), decoding: Payload.self)
        } catch {
            decodingError = error

            if case let .decoder(error) = error {
                underlyingDecodingError = error
            }
        }

        do {
            _ = try await serviceActor.resume(for: TransportEndpoint(), expecting: Payload.self)
        } catch {
            expectingError = error
        }

        // Then
        XCTAssertEqual(decodingError?.stringValue, "decoder")
        XCTAssertEqual(expectingError?.stringValue, "decoder")
        XCTAssertNotNil(underlyingDecodingError)
    }

    func testAPerCallDecoderIsHonoredAndOmittingItFallsBackToTheServiceConfiguredDecoder() async throws {
        // Given
        let body: Data = .init("{\"display_name\":\"atom\"}".utf8)
        let convertingDecoder: JSONDecoder = .init()

        convertingDecoder.keyDecodingStrategy = .convertFromSnakeCase

        StubURLProtocol.arm(with: .success(statusCode: 200, data: body))

        let serviceConfiguration: ServiceConfiguration = .init(decoder: JSONDecoder())
        let serviceActor: ServiceActor = .init(serviceConfiguration: serviceConfiguration, session: StubURLProtocol.session)

        // When
        let decoded: DecodedResponse<SnakeCasePayload> = try await serviceActor.resume(
            for: TransportEndpoint(),
            decoding: SnakeCasePayload.self,
            decoder: convertingDecoder
        )

        var serviceDecoderError: AtomError?

        do {
            _ = try await serviceActor.resume(for: TransportEndpoint(), decoding: SnakeCasePayload.self)
        } catch {
            serviceDecoderError = error
        }

        // Then
        XCTAssertEqual(decoded.model.displayName, "atom")
        XCTAssertEqual(serviceDecoderError?.stringValue, "decoder")
    }

    func testRequestingDataBackSkipsTheDecoderEntirelyFromBothEntryPoints() async throws {
        // Given
        let body: Data = .init("{\"value\":\"atom\"}".utf8)

        StubURLProtocol.arm(with: .success(statusCode: 200, data: body))

        let serviceConfiguration: ServiceConfiguration = .init()
        let serviceActor: ServiceActor = .init(serviceConfiguration: serviceConfiguration, session: StubURLProtocol.session)

        // When
        let decoded: DecodedResponse<Data> = try await serviceActor.resume(for: TransportEndpoint(), decoding: Data.self)
        let expected: Data = try await serviceActor.resume(for: TransportEndpoint(), expecting: Data.self)

        // Then
        XCTAssertEqual(decoded.model, body)
        XCTAssertEqual(decoded.response.data, body)
        XCTAssertEqual(expected, body)
    }

    func testTheCompletionVariantDeliversTheDecodedResponseOnTheConfiguredQueue() {
        // Given
        let body: Data = .init("{\"value\":\"atom\"}".utf8)
        let expectation: XCTestExpectation = .init(description: "The completion handler is called.")

        StubURLProtocol.arm(with: .success(statusCode: 200, data: body))

        let serviceConfiguration: ServiceConfiguration = .init()
        let serviceActor: ServiceActor = .init(serviceConfiguration: serviceConfiguration, session: StubURLProtocol.session)

        // When
        let recorder: DecodedResponseRecorder = .init()

        Task {
            await serviceActor.resume(for: TransportEndpoint(), decoding: Payload.self) { result in
                recorder.record(result: result)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)

        // Then
        XCTAssertEqual(recorder.decoded?.model.value, "atom")
        XCTAssertEqual(recorder.decoded?.response.statusCode, 200)
    }
}

// MARK: - DecodedResponseRecorder

/// Carries the completion handler's result back to the test body across isolation.
private final class DecodedResponseRecorder: @unchecked Sendable {
    // MARK: - Properties

    /// The lock guarding the recorded value, since the completion handler is `Sendable`.
    private let lock: NSLock = .init()

    /// The decoded response the completion handler was called with.
    private var recorded: DecodedResponse<Payload>?

    // MARK: - Computed Properties

    /// Returns the decoded response the completion handler was called with, if any.
    var decoded: DecodedResponse<Payload>? {
        lock.lock()

        defer { lock.unlock() }

        return recorded
    }

    // MARK: - Functions

    /// Records the result the completion handler was called with.
    ///
    /// - Parameters:
    ///   - result: The result to record.
    func record(result: Result<DecodedResponse<Payload>, AtomError>) {
        lock.lock()

        defer { lock.unlock() }

        recorded = try? result.get()
    }
}

// MARK: - Payload

/// A model the stubbed body decodes into with a default `JSONDecoder`.
private struct Payload: Model, Equatable {
    let value: String
}

// MARK: - SnakeCasePayload

/// A model the stubbed body only decodes into when the decoder converts from snake case.
private struct SnakeCasePayload: Model, Equatable {
    let displayName: String
}
