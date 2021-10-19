// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureInterestDomain
import PlatformKit

struct InterestAccountSelectionEnvironment {
    let fiatCurrencyService: FiatCurrencyPublisherAPI
    let accountOverviewRepository: InterestAccountOverviewRepositoryAPI
    let accountBalanceRepository: InterestAccountBalanceRepositoryAPI
    let accountRepository: BlockchainAccountRepositoryAPI
    let priceService: PriceServiceAPI
    let blockchainAccountRepository: BlockchainAccountRepositoryAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension InterestAccountSelectionEnvironment {
    static let `default`: InterestAccountSelectionEnvironment = .init(
        fiatCurrencyService: resolve(),
        accountOverviewRepository: resolve(),
        accountBalanceRepository: resolve(),
        accountRepository: resolve(),
        priceService: resolve(),
        blockchainAccountRepository: resolve(),
        mainQueue: .main
    )
}
