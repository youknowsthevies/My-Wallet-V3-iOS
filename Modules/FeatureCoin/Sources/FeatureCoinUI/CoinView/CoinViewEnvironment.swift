// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Foundation

public struct CoinViewEnvironment: BlockchainNamespaceAppEnvironment {

    public let app: AppProtocol
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>
    public let accountsProvider: () -> AnyPublisher<[Account], Error>
    public let historicalPriceService: HistoricalPriceServiceAPI
    public let interestRatesRepository: RatesRepositoryAPI
    public let explainerService: ExplainerService
    let watchlistService: WatchlistService
    public let dismiss: () -> Void

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        accountsProvider: @escaping () -> AnyPublisher<[Account], Error>,
        historicalPriceService: HistoricalPriceServiceAPI,
        interestRatesRepository: RatesRepositoryAPI,
        explainerService: ExplainerService,
        watchlistService: WatchlistService,
        dismiss: @escaping () -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
        self.accountsProvider = accountsProvider
        self.historicalPriceService = historicalPriceService
        self.interestRatesRepository = interestRatesRepository
        self.explainerService = explainerService
        self.watchlistService = watchlistService
        self.dismiss = dismiss
    }
}

extension CoinViewEnvironment {
    static var preview: Self = .init(
        app: App.preview,
        kycStatusProvider: { .empty() },
        accountsProvider: { .empty() },
        historicalPriceService: PreviewHelper.HistoricalPriceService(),
        interestRatesRepository: PreviewHelper.InterestRatesRepository(),
        explainerService: .init(app: App.preview),
        watchlistService: WatchlistService(
            base: .bitcoin,
            watchlistRepository: PreviewHelper.WatchlistRepository(),
            app: App.preview
        ),
        dismiss: {}
    )
}
