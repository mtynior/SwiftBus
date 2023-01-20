//
//  EventBus.swift
//  SwifftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation
import Combine

public final class EventBus: EventTransmittable {
    private let listenersRegistry: EventListenersRegistry
    
    /// EventBus unique identifier.
    public let id: String
    
    /// Creates an instance of the EventBus
    ///
    /// - Parameters:
    ///     - id: EventBus identifier.
    public init(id: String = UUID().uuidString) {
        self.id = id
        self.listenersRegistry = EventListenersRegistry()
    }
    
    public func send<E>(_ event: E) where E: EventRepresentable {
        guard let listener = listenersRegistry.getListener(forEventType: E.self) else { return }
        
        listener.send(event)
    }
    
    @discardableResult
    public func onReceive<E>(_ eventType: E.Type, perform action: @escaping (E) -> Void) -> AnyCancellable where E: EventRepresentable {
        let listener: EventListener = getOrCreateEventListener(for: E.self)
        return listener.registerSubscription(action: action)
    }
    
    @discardableResult
    public func onReceive<E: EventRepresentable, S: Scheduler>(_ eventType: E.Type, performOn scheduler: S, action: @escaping (E) -> Void) -> AnyCancellable {
        let listener: EventListener = getOrCreateEventListener(for: E.self)
        return listener.registerSubscription(scheduler: scheduler, action: action)
    }
}

// MARK: - helpers
private extension EventBus {
    func getOrCreateEventListener<E: EventRepresentable>(for eventType: E.Type) -> EventListener {
        guard let listener = listenersRegistry.getListener(forEventType: E.self) else {
            return listenersRegistry.createListener(forEventType: E.self)
        }
        return listener
    }
}
