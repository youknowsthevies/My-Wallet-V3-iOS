//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import PlatformUIKit
import SwiftUI
import ToolKit

struct PricesView: UIViewControllerRepresentable {

    var featureFlagService: FeatureFlagsServiceAPI = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PricesViewController(
            presenter: PricesScreenPresenter(
                drawerRouter: NoDrawer(),
                interactor: PricesScreenInteractor(
                    showSupportedPairsOnly: false
                )
            ),
            featureFlagService: featureFlagService
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}

class NoDrawer: DrawerRouting {
    func toggleSideMenu() {}
    func closeSideMenu() {}
}
