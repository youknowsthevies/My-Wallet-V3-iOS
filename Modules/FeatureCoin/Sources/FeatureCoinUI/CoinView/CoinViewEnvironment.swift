// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain

public struct CoinViewEnvironment: BlockchainNamespaceAppEnvironment {

    public let app: AppProtocol
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>
    let accountsProvider: () -> AnyPublisher<[Account], Never>
    let historicalPriceService: HistoricalPriceServiceAPI
    let interestRatesRepository: RatesRepositoryAPI

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        app: AppProtocol,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        accountsProvider: @escaping () -> AnyPublisher<[Account], Never>,
        historicalPriceService: HistoricalPriceServiceAPI,
        interestRatesRepository: RatesRepositoryAPI
    ) {
        self.mainQueue = mainQueue
        self.app = app
        self.kycStatusProvider = kycStatusProvider
        self.accountsProvider = accountsProvider
        self.historicalPriceService = historicalPriceService
        self.interestRatesRepository = interestRatesRepository
    }
}
