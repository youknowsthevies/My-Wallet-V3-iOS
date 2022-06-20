// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardIssuingDomain

extension DependencyContainer {

    // MARK: - FeatureCardIssuingUI Module

    public static var featureCardIssuingUI = module {

        factory {
            CardIssuingBuilder(
                accountModelProvider: DIKit.resolve(),
                cardService: DIKit.resolve(),
                productService: DIKit.resolve(),
                supportRouter: DIKit.resolve(),
                topUpRouter: DIKit.resolve()
            ) as CardIssuingBuilderAPI
        }
    }
}
