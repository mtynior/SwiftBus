//
//  EventTransmittable.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation
import Combine

public protocol EventTransmittable: AnyObject {
    /// Sends an event.
    ///
    /// - Parameters:
    ///     - event: An instance of the event that conforms to the `EventRepresentable` protocol.
    func send<E: EventRepresentable>(_ event: E)
    
    /// Sends a named event.
    ///
    /// - Parameters:
    ///     - eventName: Name of the event.
    ///     - params: Optional event data.
    func send(_ eventName: String, params: [AnyHashable: Any])
    
    /// Triggers action when EventBus emits an event.
    ///
    /// - Parameters:
    ///     - eventType: Type of an event that triggers the action.
    ///     - action: The action to perform when an event is emitted by EventBus. The  event instance is passed as a parameter to action.
    /// - Returns: A cancellable instance, which needs to be stored as long as action needs to be triggered. Deallocation of the result will unsubscribe from the event and action will not be triggered.
    @discardableResult func onReceive<E: EventRepresentable>(_ eventType: E.Type, perform action: @escaping (E) -> Void) -> AnyCancellable
    
    /// Triggers action on specific scheduler when EventBus emits an event.
    ///
    /// - Parameters:
    ///     - eventType: Type of an event that triggers the action.
    ///     - scheduler: The scheduler that is used to perform action.
    ///     - action: The action to perform when an event is emitted by EventBus. The  event instance is passed as a parameter to action.
    /// - Returns: A cancellable instance, which needs to be stored as long as action needs to be triggered. Deallocation of the result will unsubscribe from the event and action will not be triggered.
    @discardableResult func onReceive<E: EventRepresentable, S: Scheduler>(_ eventType: E.Type, performOn scheduler: S, action: @escaping (E) -> Void) -> AnyCancellable
    
    /// Triggers action when EventBus emits a named event.
    ///
    /// - Parameters:
    ///     - eventName: Name of the event.
    ///     - action: The action to perform when an event is emitted by EventBus. The  event data is passed as a parameter to action.
    /// - Returns: A cancellable instance, which needs to be stored as long as action needs to be triggered. Deallocation of the result will unsubscribe from the event and action will not be triggered.
    @discardableResult func onReceive(_ eventName: String, perform action: @escaping ([AnyHashable: Any]) -> Void) -> AnyCancellable
    
    /// Triggers action on specific scheduler when EventBus emits a named event.
    ///
    /// - Parameters:
    ///     - eventName: Name of the event.
    ///     - scheduler: The scheduler that is used to perform action.
    ///     - action: The action to perform when an event is emitted by EventBus. The  event data is passed as a parameter to action.
    /// - Returns: A cancellable instance, which needs to be stored as long as action needs to be triggered. Deallocation of the result will unsubscribe from the event and action will not be triggered.
    @discardableResult func onReceive<S: Scheduler>(_ eventName: String, performOn scheduler: S, action: @escaping ([AnyHashable: Any]) -> Void) -> AnyCancellable
}

// MARK: - Named event
public extension EventTransmittable {
    func send(_ eventName: String, params: [AnyHashable: Any] = [:]) {
        let namedEvent = NamedEvent(name: eventName, params: params)
        send(namedEvent)
    }
    
    @discardableResult
    func onReceive(_ eventName: String, perform action: @escaping ([AnyHashable: Any]) -> Void) -> AnyCancellable {
        return onReceive(NamedEvent.self) { event in
            guard event.name == eventName else { return }
            action(event.params)
        }
    }
    
    @discardableResult
    func onReceive<S: Scheduler>(_ eventName: String, performOn scheduler: S, action: @escaping ([AnyHashable: Any]) -> Void) -> AnyCancellable {
        return onReceive(NamedEvent.self, performOn: scheduler) { event in
            guard event.name == eventName else { return }
            action(event.params)
        }
    }
}
