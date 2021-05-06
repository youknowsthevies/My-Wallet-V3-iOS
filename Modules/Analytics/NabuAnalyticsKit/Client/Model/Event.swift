// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum EventType: String, Encodable {
    case event = "EVENT"
}

struct Event: Encodable {
    let originalTimestamp: Date
    let name: String
    var type: EventType
    let properties: [String: String]?
}
