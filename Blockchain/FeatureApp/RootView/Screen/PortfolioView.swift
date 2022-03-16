//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardUI
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit

struct PortfolioView: UIViewControllerRepresentable {

    let store: Store<Void, RootViewAction>

    init(store: Store<Void, RootViewAction>) {
        self.store = store
    }

    private var fiatBalanceCellProvider: FiatBalanceCellProviding = resolve()
    private var onboardingViewsFactory = OnboardingViewsFactory()
    private var userAdapter: UserAdapterAPI = resolve()
    private var featureFlagService: FeatureFlagsServiceAPI = resolve()

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
            presentRedesignCoinView: { _, cryptoCurrency in
                ViewStore(store).send(.enter(into: .coinView(cryptoCurrency)))
            }
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
