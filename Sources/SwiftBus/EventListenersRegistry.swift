//
//  EventListenersRegistry.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation

internal final class EventListenersRegistry {
    private(set) var listeners: [EventListener] = []
        
    func getListener<E: EventRepresentable>(forEventType eventType: E.Type) -> EventListener? {
        return listeners.first(where: { $0.eventType == eventType })
    }
    
    func createListener<E: EventRepresentable>(forEventType eventType: E.Type) -> EventListener {
        let eventListener = EventListener(eventType: eventType)
        listeners.append(eventListener)
        return eventListener
    }
}
