//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import PlatformKit
import PlatformUIKit
import SwiftUI

struct PortfolioView: UIViewControllerRepresentable {

    var fiatBalanceCellProvider: FiatBalanceCellProviding = resolve()
    var onboardingViewsFactory = OnboardingViewsFactory()
    var userAdapter: UserAdapterAPI = resolve()

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
            presenter: PortfolioScreenPresenter(drawerRouter: NoDrawer())
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
