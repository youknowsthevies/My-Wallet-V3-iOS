// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct EventsWrapper: Encodable {
    let id: String?
    let context: Context
    let events: [Event]

    init(contextProvider: ContextProviding, events: [Event]) {
        self.id = contextProvider.anonymousId
        self.context = contextProvider.context
        self.events = events
    }
}
