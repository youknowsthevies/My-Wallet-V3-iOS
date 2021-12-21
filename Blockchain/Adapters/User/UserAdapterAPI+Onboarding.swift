//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI

extension UserAdapterAPI {

    /// A publisher that streams `FeatureOnboardingUI.UserState` values on subscription and on change by mapping values streamed by `userState`
    var onboardingUserState: AnyPublisher<FeatureOnboardingUI.UserState, Never> {
        userState
            .map { userState -> FeatureOnboardingUI.UserState in
                FeatureOnboardingUI.UserState(
                    hasCompletedKYC: userState.kycStatus.canPurchaseCrypto,
                    hasLinkedPaymentMethods: !userState.linkedPaymentMethods.isEmpty,
                    hasEverPurchasedCrypto: userState.hasEverPurchasedCrypto
                )
            }
            .eraseToAnyPublisher()
    }
}
