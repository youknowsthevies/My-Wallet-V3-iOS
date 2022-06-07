// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

class MockExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    // MARK: - Mock Properties

    var syncDepositAddressesIfLinkedCalled: Bool = false

    // MARK: - ExchangeAccountRepositoryAPI

    func syncDepositAddressesIfLinked() -> AnyPublisher<Void, ExchangeAccountRepositoryError> {
        syncDepositAddressesIfLinkedCalled = true
        return .just(())
    }
}
