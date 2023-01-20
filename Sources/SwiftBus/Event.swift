//
//  Event.swift
//  SwiftBus
//
//  Created by Michal Tynior on 20/01/2023.
//

import Foundation

public protocol EventRepresentable {}

public struct NamedEvent: EventRepresentable {
    public let name: String
    public let params: [AnyHashable: Any]
    
    public init(name: String, params: [AnyHashable: Any] = [:]) {
        self.name = name
        self.params = params
    }
}
