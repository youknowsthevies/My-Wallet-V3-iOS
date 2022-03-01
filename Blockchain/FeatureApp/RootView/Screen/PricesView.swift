//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import FeatureCoinDomain
import FeatureCoinUI
import FeatureDashboardUI
import PlatformUIKit
import SwiftUI
import ToolKit

struct PricesView: UIViewControllerRepresentable {

    var featureFlagService: FeatureFlagsServiceAPI = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let presenter = PricesScreenPresenter(
            drawerRouter: NoDrawer(),
            interactor: PricesScreenInteractor(
                showSupportedPairsOnly: false
            )
        )
        let viewController = PricesViewController(
            presenter: presenter,
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

class NoDrawer: DrawerRouting {
    func toggleSideMenu() {}
    func closeSideMenu() {}
}
