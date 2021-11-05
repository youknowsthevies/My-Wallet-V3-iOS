// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

class MockExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    // MARK: - Mock Properties

    var hasLinkedExchangeAccountValue: Bool = false
    var syncDepositAddressesIfLinkedCalled: Bool = false

    // MARK: - ExchangeAccountRepositoryAPI

    var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountRepositoryError> {
        .just(hasLinkedExchangeAccountValue)
    }

    func syncDepositAddresses() -> AnyPublisher<Void, ExchangeAccountRepositoryError> {
        .just(())
    }

    func syncDepositAddressesIfLinked() -> AnyPublisher<Void, ExchangeAccountRepositoryError> {
        syncDepositAddressesIfLinkedCalled = true
        return .just(())
    }
}
