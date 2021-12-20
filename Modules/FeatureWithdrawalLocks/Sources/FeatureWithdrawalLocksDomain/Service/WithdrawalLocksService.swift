// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public protocol WithdrawalLocksServiceAPI {
    func withdrawalLocks() -> AnyPublisher<WithdrawalLocks, Never>
}

final class WithdrawalLocksService: WithdrawalLocksServiceAPI {
    func withdrawalLocks() -> AnyPublisher<WithdrawalLocks, Never> {
        fiatCurrencyCodePublisher.defaultFiatCurrencyCode
            .flatMap { [repository] currencyCode in
                repository.withdrawalLocks(currencyCode: currencyCode)
            }
            .eraseToAnyPublisher()
    }

    private let repository: WithdrawalLocksRepositoryAPI
    private let fiatCurrencyCodePublisher: FiatCurrencyCodeProviderAPI

    init(
        repository: WithdrawalLocksRepositoryAPI = resolve(),
        fiatCurrencyCodePublisher: FiatCurrencyCodeProviderAPI = resolve()
    ) {
        self.repository = repository
        self.fiatCurrencyCodePublisher = fiatCurrencyCodePublisher
    }
}
