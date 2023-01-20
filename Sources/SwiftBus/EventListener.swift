//
//  EventListener.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation
import Combine

internal final class EventListener {
    let id: String
    let eventType: EventRepresentable.Type
    let publisher: PassthroughSubject<EventRepresentable, Never>
    
    init(id: String = UUID().uuidString, eventType: EventRepresentable.Type) {
        self.id = id
        self.eventType = eventType
        self.publisher = PassthroughSubject<EventRepresentable, Never>()
    }
    
    func send(_ event: EventRepresentable) {
        self.publisher.send(event)
    }
    
    func registerSubscription<E: EventRepresentable>(action: @escaping (E) -> Void) -> AnyCancellable {
        return publisher.sink {
            guard let event = $0 as? E else { return }
            action(event)
        }
    }
    
    func registerSubscription<E: EventRepresentable, S: Scheduler>(scheduler: S, action: @escaping (E) -> Void) -> AnyCancellable {
        return publisher
            .receive(on: scheduler)
            .sink {
                guard let event = $0 as? E else { return }
                action(event)
            }
    }
}
