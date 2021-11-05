// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public protocol WithdrawalLocksServiceAPI {
    var withdrawLocks: AnyPublisher<WithdrawalLocks, Never> { get }
}

final class WithdrawalLocksService: WithdrawalLocksServiceAPI {

    lazy var withdrawLocks: AnyPublisher<WithdrawalLocks, Never> = {
        fiatCurrencyCodePublisher.defaultFiatCurrencyCode
            .flatMap { [repository] currencyCode in
                repository.withdrawLocks(currencyCode: currencyCode)
            }
            .share()
            .eraseToAnyPublisher()
    }()

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
