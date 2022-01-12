// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardsDomain

extension DependencyContainer {

    // MARK: - FeatureCardsUI Module

    public static var featureCardsUI = module {
        factory { StripeUIClient() as StripeUIClientAPI }
    }
}
