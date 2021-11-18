//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import PlatformUIKit
import SwiftUI

struct PortfolioView: UIViewControllerRepresentable {

    var dashboardScreenPresenter: PortfolioScreenPresenter = .init()
    var fiatBalanceCellProvider: FiatBalanceCellProviding = resolve()

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PortfolioViewController(
            fiatBalanceCellProvider: fiatBalanceCellProvider,
            presenter: dashboardScreenPresenter
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
