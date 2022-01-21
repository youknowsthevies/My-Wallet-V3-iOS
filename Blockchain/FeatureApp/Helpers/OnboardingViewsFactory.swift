//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import FeatureOnboardingUI
import PlatformKit
import PlatformUIKit
import SwiftUI

final class OnboardingViewsFactory {

    private let kycAdapter: KYCAdapter
    private let userAdapter: UserAdapterAPI
    private let transactionsAdapter: TransactionsAdapterAPI
    private let paymentMethodLinkingAdapter: PaymentMethodsLinkingAdapterAPI

    init(
        kycAdapter: KYCAdapter = KYCAdapter(),
        userAdapter: UserAdapterAPI = resolve(),
        transactionsAdapter: TransactionsAdapterAPI = resolve(),
        paymentMethodLinkingAdapter: PaymentMethodsLinkingAdapterAPI = resolve()
    ) {
        self.kycAdapter = kycAdapter
        self.userAdapter = userAdapter
        self.transactionsAdapter = transactionsAdapter
        self.paymentMethodLinkingAdapter = paymentMethodLinkingAdapter
    }

    func makeOnboardingChecklistOverview() -> some View {
        OnboardingChecklistOverview(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: makeOnboardingChecklistEnvironment()
            )
        )
    }

    func makeOnboardingChecklistView() -> some View {
        OnboardingChecklistView(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: makeOnboardingChecklistEnvironment()
            )
        )
    }

    private func makeOnboardingChecklistEnvironment() -> OnboardingChecklist.Environment {
        OnboardingChecklist.Environment(
            userState: userAdapter.onboardingUserState,
            presentBuyFlow: { [transactionsAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    transactionsAdapter.presentTransactionFlow(
                        to: .buy(nil),
                        from: viewController
                    ) { result in
                        // view is dismissed automatically, so, no need to do that
                        completion(result == .completed)
                    }
                }
            },
            presentKYCFlow: { [kycAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    kycAdapter.presentKYCIfNeeded(
                        from: viewController,
                        requireEmailVerification: true,
                        requiredTier: .tier2
                    ) { result in
                        // view is dismissed automatically, so, no need to do that
                        completion(result == .completed)
                    }
                }
            },
            presentPaymentMethodLinkingFlow: { [paymentMethodLinkingAdapter] completion in
                if let viewController = UIApplication.shared.topMostViewController {
                    paymentMethodLinkingAdapter.routeToPaymentMethodLinkingFlow(
                        from: viewController,
                        completion: { result in
                            viewController.dismiss(animated: true) {
                                completion(result == .completed)
                            }
                        }
                    )
                }
            }
        )
    }
}
