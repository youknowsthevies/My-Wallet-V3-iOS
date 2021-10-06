// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureInterestDomain
import PlatformKit

enum InterestAccountSelectionError: Error {
    case unknown
}

struct InterestAccountSelectionEnvironment {
    let fiatCurrencyService: FiatCurrencyPublisherAPI
    let accountOverviewRepository: InterestAccountOverviewRepositoryAPI
    let accountBalanceRepository: InterestAccountBalanceRepositoryAPI
    let accountRepository: BlockchainAccountRepositoryAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
}

extension InterestAccountSelectionEnvironment {
    static let `default`: InterestAccountSelectionEnvironment = .init(
        fiatCurrencyService: resolve(),
        accountOverviewRepository: resolve(),
        accountBalanceRepository: resolve(),
        accountRepository: resolve(),
        mainQueue: .main
    )
}
