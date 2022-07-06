// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Event: Codable, Equatable {
    var originalTimestamp: Date
    let name: String
    var type: EventType
    let properties: [String: JSONValue]?

    init(title: String, properties: [String: Any?]?) {
        originalTimestamp = Date()
        name = title
        type = .event
        self.properties = properties?.compactMapValues(JSONValue.init)
    }
}
