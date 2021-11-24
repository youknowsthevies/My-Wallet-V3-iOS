//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import FeatureDashboardUI
import SwiftUI

struct PricesView: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PricesViewController()
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
