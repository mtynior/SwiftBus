//
//  EventTransmittable.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation
import Combine

public protocol EventTransmittable: AnyObject {
    func send<E: EventRepresentable>(_ event: E)
    @discardableResult func onReceive<E: EventRepresentable>(_ eventType: E.Type, perform action: @escaping (E) -> Void) -> AnyCancellable
    @discardableResult func onReceive<E: EventRepresentable, S: Scheduler>(_ eventType: E.Type, performOn scheduler: S, action: @escaping (E) -> Void) -> AnyCancellable
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
