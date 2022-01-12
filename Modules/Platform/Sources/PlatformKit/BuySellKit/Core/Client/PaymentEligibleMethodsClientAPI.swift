// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureCardsDomain
import NabuNetworkError

public protocol PaymentEligibleMethodsClientAPI: EligibleCardAcquirersAPI {

    func eligiblePaymentMethods(
        for currency: String,
        currentTier: KYC.Tier,
        sddEligibleTier: Int?
    ) -> AnyPublisher<[PaymentMethodsResponse.Method], NabuNetworkError>
}
