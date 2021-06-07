// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct EventsWrapper: Encodable {
    let id: String?
    let platform: String = "WALLET"
    let context: Context
    let events: [Event]

    init(contextProvider: ContextProviderAPI, events: [Event]) {
        self.id = contextProvider.anonymousId
        self.context = contextProvider.context
        self.events = events
    }
}
