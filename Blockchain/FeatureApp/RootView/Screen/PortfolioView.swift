//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

struct PortfolioView: UIViewControllerRepresentable {

    var fiatBalanceCellProvider: FiatBalanceCellProviding = resolve()
    var onboardingViewsFactory = OnboardingViewsFactory()
    var userAdapter: UserAdapterAPI = resolve()
    var featureFlagService: FeatureFlagsServiceAPI = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PortfolioViewController(
            fiatBalanceCellProvider: fiatBalanceCellProvider,
            userHasCompletedOnboarding: userAdapter
                .onboardingUserState
                .map { $0.kycStatus == .complete && $0.hasEverPurchasedCrypto }
                .eraseToAnyPublisher(),
            onboardingChecklistViewBuilder: { [onboardingViewsFactory] in
                onboardingViewsFactory.makeOnboardingChecklistOverview()
            },
            presenter: PortfolioScreenPresenter(drawerRouter: NoDrawer()),
            featureFlagService: featureFlagService,
            presentRedesignCoinView: { vc, cryptoCurrency in
                vc.present(
                    CoinAdapterView(cryptoCurrency: cryptoCurrency),
                    inNavigationController: false
                )
            }
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
