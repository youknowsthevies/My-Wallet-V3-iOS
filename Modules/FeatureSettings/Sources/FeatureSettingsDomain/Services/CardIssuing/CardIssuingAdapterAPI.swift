// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol CardIssuingAdapterAPI {

    func isEnabled() -> AnyPublisher<Bool, Never>
    func hasCard() -> AnyPublisher<Bool, Never>
}
