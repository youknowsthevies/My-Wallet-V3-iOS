// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Event: Encodable {
    var originalTimestamp: Date
    let name: String
    var type: EventType
    let properties: [String: JSONValue]?
    
    init(title: String, properties: [String: Any]?) {
        self.originalTimestamp = Date()
        self.name = title
        self.type = .event
        
        self.properties = properties?.compactMapValues { value -> JSONValue? in
            switch value {
            case let value as String:
                return .string(value)
            case let value as Int:
                return .int(value)
            case let value as Double:
                return .double(value)
            case let value as Bool:
                return .bool(value)
            default:
                return nil
            }
        }
    }
}
