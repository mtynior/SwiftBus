//
//  Event.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation

/// A protocol that represents an event that can be sent and received by EventBus
public protocol EventRepresentable {}

internal struct NamedEvent: EventRepresentable {
    internal let name: String
    internal let params: [AnyHashable: Any]
    
    internal init(name: String, params: [AnyHashable: Any] = [:]) {
        self.name = name
        self.params = params
    }
}
