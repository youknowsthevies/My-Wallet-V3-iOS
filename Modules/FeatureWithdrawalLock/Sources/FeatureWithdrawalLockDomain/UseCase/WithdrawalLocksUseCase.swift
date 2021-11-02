// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NabuNetworkError
import PlatformKit
import ToolKit

public protocol WithdrawalLocksUseCaseAPI {
    var withdrawLocks: AnyPublisher<WithdrawalLocks, Never> { get }
}

class WithdrawalLocksUseCase: WithdrawalLocksUseCaseAPI {

    private let repository: WithdrawalLocksRepositoryAPI
    private let fiatCurrencyPublisher: FiatCurrencyPublisherAPI

    init(
        repository: WithdrawalLocksRepositoryAPI = resolve(),
        fiatCurrencyPublisher: FiatCurrencyPublisherAPI = resolve()
    ) {
        self.repository = repository
        self.fiatCurrencyPublisher = fiatCurrencyPublisher
    }

    lazy var withdrawLocks: AnyPublisher<WithdrawalLocks, Never> = {
        fiatCurrencyPublisher.fiatCurrencyPublisher
            .flatMap { [repository] currency in
                repository.withdrawLocks(currencyCode: currency.code)
                    .ignoreFailure()
            }
            .shareReplay()
            .eraseToAnyPublisher()
    }()
}
