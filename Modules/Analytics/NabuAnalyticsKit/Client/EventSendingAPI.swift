// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

protocol EventSendingAPI {
    func publish(events: EventsWrapper) -> AnyPublisher<Void, NetworkError>
}
