// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureCardPaymentDomain

extension DependencyContainer {

    // MARK: - FeatureCardPaymentUI Module

    public static var featureCardPaymentUI = module {
        factory { StripeUIClient() as StripeUIClientAPI }
    }
}
