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
    public let assetInformationService: AssetInformationService
    public let historicalPriceService: HistoricalPriceService
    public let interestRatesRepository: RatesRepositoryAPI
    public let explainerService: ExplainerService
    public let dismiss: () -> Void

    private let watchlistService: WatchlistService

    public init(
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        accountsProvider: @escaping () -> AnyPublisher<[Account], Error>,
        assetInformationService: AssetInformationService,
        historicalPriceService: HistoricalPriceService,
        interestRatesRepository: RatesRepositoryAPI,
        explainerService: ExplainerService,
        watchlistService: WatchlistService,
        dismiss: @escaping () -> Void
    ) {
        self.app = app
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
        self.accountsProvider = accountsProvider
        self.assetInformationService = assetInformationService
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
        assetInformationService: .preview,
        historicalPriceService: .preview,
        interestRatesRepository: PreviewRatesRepository(.just(5 / 3)),
        explainerService: .preview,
        watchlistService: .preview,
        dismiss: {}
    )

    static var previewEmpty: Self = .init(
        app: App.preview,
        kycStatusProvider: { .empty() },
        accountsProvider: { .empty() },
        assetInformationService: .previewEmpty,
        historicalPriceService: .previewEmpty,
        interestRatesRepository: PreviewRatesRepository(),
        explainerService: .preview,
        watchlistService: .previewEmpty,
        dismiss: {}
    )
}
