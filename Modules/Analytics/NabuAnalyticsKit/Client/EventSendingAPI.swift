// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol EventSendingAPI {
    func post(events: EventsWrapper)
}
