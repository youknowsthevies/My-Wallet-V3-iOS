//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI

extension UserAdapterAPI {

    /// A publisher that streams `FeatureOnboardingUI.UserState` values on subscription and on change by mapping values streamed by `userState`
    var onboardingUserState: AnyPublisher<FeatureOnboardingUI.UserState, Never> {
        userState
            .compactMap { result -> UserState? in
                guard case .success(let userState) = result else {
                    return nil
                }
                return userState
            }
            .map { userState -> FeatureOnboardingUI.UserState in
                FeatureOnboardingUI.UserState(
                    kycStatus: .init(userState.kycStatus),
                    hasLinkedPaymentMethods: !userState.linkedPaymentMethods.isEmpty,
                    hasEverPurchasedCrypto: userState.hasEverPurchasedCrypto
                )
            }
            .eraseToAnyPublisher()
    }
}

extension FeatureOnboardingUI.UserState.KYCStatus {

    init(_ kycStatus: UserState.KYCStatus) {
        switch kycStatus {
        case .unverified, .silver:
            self = .incomplete
        case .gold, .silverPlus:
            self = .complete
        case .inReview:
            self = .pending
        }
    }
}
