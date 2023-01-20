//
//  EventBusTests.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import XCTest
@testable import SwiftBus
import Combine

final class EventBusTests: XCTestCase {
    var eventBus: EventBus!
    var subscriptions: [AnyCancellable]!
    
    override func setUpWithError() throws {
        eventBus  = EventBus()
        subscriptions = []
    }

    override func tearDownWithError() throws {
        eventBus = nil
        subscriptions = nil
    }
}

// MARK: - Custom event
extension EventBusTests {
    func testSendingAndReceivingCustomEvent() throws {
        // given
        let expectedEvent = CustomEvent(message: "Luke, I'm your father")
        
        // and
        let eventExpectation = expectation(description: "Should receive custom event")
        eventBus.onReceive(CustomEvent.self) { actualEvent in
            if actualEvent == expectedEvent {
                eventExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(expectedEvent)
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testSendingOneEventAndListeningForAnotherEvent() throws {
        // given
        let eventExpectation = expectation(description: "Should not receive an event")
        eventExpectation.isInverted = true
        
        eventBus.onReceive(AnotherEvent.self) { _ in
            eventExpectation.fulfill()
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(CustomEvent(message: ""))
        
        // then
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Named event
extension EventBusTests {
    func testSendingAndReceivingNamedEventWithCustomParams() throws {
        // given
        let expectedParams: [String: Any] = [
            "planet": "Hoth",
            "distanceInParsecs": 10
        ]
        
        // end
        let eventExpectation = expectation(description: "Should receive named event with custom parameters")
        eventBus.onReceive(TestEvents.rebelsDetected) { actualParams in
            if actualParams.isEqual(to: expectedParams) {
                eventExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(TestEvents.rebelsDetected, params: expectedParams)
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testSendingAndReceivingNamedEventWithoutParams() throws {
        // given
        let eventExpectation = expectation(description: "Should receive named event without parameters")
        eventBus.onReceive(TestEvents.rebelsDetected) { params in
            if params.isEmpty {
                eventExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(TestEvents.rebelsDetected)
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testSendingNamesEventAndListeningForAnotherEvent() throws {
        // given
        let threadExpectation = expectation(description: "Should not receive an event")
        threadExpectation.isInverted = true
        
        eventBus.onReceive(TestEvents.prepareFleetToJumpIntoHyperspace) { _ in
            threadExpectation.fulfill()
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(TestEvents.rebelsDetected)
        
        // then
        waitForExpectations(timeout: 1)
    }
    
    func testSendingNamesEventAndListeningForAnotherEventOnDifferentThread() throws {
        // given
        let threadExpectation = expectation(description: "Should not receive an event on the main thread")
        threadExpectation.isInverted = true
        
        eventBus.onReceive(TestEvents.prepareFleetToJumpIntoHyperspace, performOn: DispatchQueue.main) { _ in
            threadExpectation.fulfill()
        }
        .store(in: &subscriptions)
        
        // when
        DispatchQueue.global(qos: .background).async {
            self.eventBus.send(TestEvents.rebelsDetected)
        }
        
        // then
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Threading
extension EventBusTests {
    func testDefaultThread() throws {
        // given
        var sendThread: Thread?
        
        // and
        let threadExpectation = expectation(description: "Should receive an event on the same thread that was used to send the event")
        eventBus.onReceive(TestEvents.rebelsDetected) { _ in
            if Thread.current == sendThread {
                threadExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        DispatchQueue.global(qos: .background).async {
            sendThread = Thread.current
            self.eventBus.send(TestEvents.rebelsDetected)
        }
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testReceiveOnMainThread() throws {
        // given
        let threadExpectation = expectation(description: "Should receive an event on the main thread")
        eventBus.onReceive(TestEvents.rebelsDetected, performOn: DispatchQueue.main) { _ in
            if Thread.current.isMainThread {
                threadExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        DispatchQueue.global(qos: .background).async {
            self.eventBus.send(TestEvents.rebelsDetected)
        }
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testReceiveOnBackgroundThread() throws {
        // given
        let threadExpectation = expectation(description: "Should receive an event on the background thread")
        eventBus.onReceive(TestEvents.rebelsDetected, performOn: DispatchQueue.global(qos: .userInitiated)) { _ in
            if !Thread.current.isMainThread {
                threadExpectation.fulfill()
            }
        }
        .store(in: &subscriptions)
        
        // when
        DispatchQueue.main.async {
            self.eventBus.send(TestEvents.rebelsDetected)
        }
        
        // then
        waitForExpectations(timeout: 10)
    }
}

// MARK: - Other
extension EventBusTests {
    func testMultipleSubscribers() throws {
        // given
        let eventExpectation = expectation(description: "Should receive events")
        eventExpectation.expectedFulfillmentCount = 2
        
        eventBus.onReceive(AnotherEvent.self) { _ in
            eventExpectation.fulfill()
        }
        .store(in: &subscriptions)
        
        eventBus.onReceive(AnotherEvent.self) { _ in
            eventExpectation.fulfill()
        }
        .store(in: &subscriptions)
        
        // when
        eventBus.send(AnotherEvent())
        
        // then
        waitForExpectations(timeout: 10)
    }
    
    func testNotStoreReferenceWhen() throws {
        // given
        let threadExpectation = expectation(description: "Should not receive an event")
        threadExpectation.isInverted = true
        
        eventBus.onReceive(TestEvents.rebelsDetected) { _ in
            threadExpectation.fulfill()
        }
        // .store(in: &subscriptions) -> don't store subscription, so it is deallocated immediately
        
        // when
        eventBus.send(TestEvents.rebelsDetected)
        
        // then
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mocked data
private extension EventBusTests {
    struct CustomEvent: EventRepresentable, Equatable {
        let id: String = UUID().uuidString
        let message: String
    }
    
    struct AnotherEvent: EventRepresentable {}
    
    enum TestEvents {
        static let rebelsDetected = "RebelsDetected"
        static let prepareFleetToJumpIntoHyperspace = "PrepareFleetToJumpIntoHyperspace"
    }
}

// MARK: - Helpers
private extension Dictionary where Key == AnyHashable, Value == Any {
    func isEqual(to rhs: [AnyHashable: Any] ) -> Bool {
        return NSDictionary(dictionary: self).isEqual(to: rhs)
    }
}
