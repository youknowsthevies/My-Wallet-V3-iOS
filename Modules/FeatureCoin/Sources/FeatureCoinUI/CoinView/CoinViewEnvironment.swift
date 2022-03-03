// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureCoinDomain

public struct CoinViewEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>
    let accountsProvider: () -> AnyPublisher<[Account], Never>
    let historicalPriceService: HistoricalPriceServiceAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        accountsProvider: @escaping () -> AnyPublisher<[Account], Never>,
        historicalPriceService: HistoricalPriceServiceAPI
    ) {
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
        self.accountsProvider = accountsProvider
        self.historicalPriceService = historicalPriceService
    }
}
