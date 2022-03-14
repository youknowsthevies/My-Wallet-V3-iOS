// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardIssuingDomain
import FeatureSettingsDomain
import ToolKit

final class CardIssuingAdapter: CardIssuingAdapterAPI {

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let productsService: ProductsServiceAPI
    private let cardService: CardServiceAPI

    init(
        featureFlagsService: FeatureFlagsServiceAPI,
        productsService: ProductsServiceAPI,
        cardService: CardServiceAPI
    ) {
        self.featureFlagsService = featureFlagsService
        self.productsService = productsService
        self.cardService = cardService
    }

    func isEnabled() -> AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest3(
                featureFlagsService.isEnabled(.remote(.cardIssuing)),
                featureFlagsService.isEnabled(.local(.cardIssuing)),
                productsService.fetchProducts()
                    .map { !$0.isEmpty }
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            )
            .map { ($0 || $1) && $2 }
            .eraseToAnyPublisher()
    }

    func hasCard() -> AnyPublisher<Bool, Never> {
        cardService.fetchCards()
            .map { !$0.isEmpty }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
