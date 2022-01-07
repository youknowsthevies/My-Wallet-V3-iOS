//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import FeatureOnboardingUI
import PlatformKit
import PlatformUIKit
import SwiftUI

struct PortfolioView: UIViewControllerRepresentable {

    var kycAdapter = KYCAdapter()
    var userAdapter: UserAdapterAPI = resolve()
    var transactionsAdapter: TransactionsAdapterAPI = resolve()
    var paymentMethodLinkingAdapter: PaymentMethodsLinkingAdapterAPI = resolve()
    var fiatBalanceCellProvider: FiatBalanceCellProviding = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PortfolioViewController(
            fiatBalanceCellProvider: fiatBalanceCellProvider,
            userHasCompletedOnboarding: userAdapter
                .onboardingUserState
                .map { $0.hasCompletedKYC && $0.hasLinkedPaymentMethods && $0.hasEverPurchasedCrypto }
                .eraseToAnyPublisher(),
            onboardingChecklistViewBuilder: {
                OnboardingChecklistOverview(
                    store: .init(
                        initialState: OnboardingChecklist.State(),
                        reducer: OnboardingChecklist.reducer,
                        environment: OnboardingChecklist.Environment(
                            userState: userAdapter.onboardingUserState,
                            presentBuyFlow: { [transactionsAdapter] completion in
                                if let viewController = UIApplication.shared.topMostViewController {
                                    transactionsAdapter.presentTransactionFlow(
                                        to: .buy(nil),
                                        from: viewController
                                    ) { result in
                                        viewController.dismiss(animated: true) {
                                            completion(result == .completed)
                                        }
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
                                        viewController.dismiss(animated: true) {
                                            completion(result == .completed)
                                        }
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
                    )
                )
            },
            presenter: PortfolioScreenPresenter(drawerRouter: NoDrawer())
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
