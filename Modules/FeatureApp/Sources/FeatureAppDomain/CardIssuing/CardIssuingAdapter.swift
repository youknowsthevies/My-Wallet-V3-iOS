// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import FeatureCardIssuingDomain
import FeatureSettingsDomain
import ToolKit

final class CardIssuingAdapter: CardIssuingAdapterAPI {

    private let app: AppProtocol
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let productsService: ProductsServiceAPI
    private let cardService: CardServiceAPI

    init(
        app: AppProtocol,
        featureFlagsService: FeatureFlagsServiceAPI,
        productsService: ProductsServiceAPI,
        cardService: CardServiceAPI
    ) {
        self.app = app
        self.featureFlagsService = featureFlagsService
        self.productsService = productsService
        self.cardService = cardService
    }

    func isEnabled() -> AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest(
                app.publisher(for: blockchain.app.configuration.card.issuing.is.enabled, as: Bool.self)
                    .prefix(1)
                    .replaceError(with: false),
                productsService.fetchProducts()
                    .map { !$0.isEmpty }
                    .replaceError(with: false)
            )
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    func hasCard() -> AnyPublisher<Bool, Never> {
        cardService.fetchCards()
            .map { !$0.isEmpty }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
