// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardIssuingDomain

extension DependencyContainer {

    // MARK: - FeatureCardIssuingUI Module

    public static var featureCardIssuingUI = module {

        factory {
            CardIssuingBuilder(
                cardService: DIKit.resolve(),
                productService: DIKit.resolve()
            ) as CardIssuingBuilderAPI
        }
    }
}
