// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct EventsWrapper: Encodable {
    let id: String
    let context: Context
    let events: [Event]
    
    init(context: Context, events: [Event]) {
        self.id = UUID().uuidString
        self.context = context
        self.events = events
    }
}
