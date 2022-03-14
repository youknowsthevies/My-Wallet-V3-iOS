// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

/// A service API that aggregates card addition logic
public protocol CardUpdateServiceAPI: AnyObject {
    func add(
        card: CardData,
        email: AnyPublisher<String, Never>,
        currency: AnyPublisher<FiatCurrency, Never>
    ) -> AnyPublisher<PartnerAuthorizationData, Error>
}
