//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureDashboardUI
import PlatformUIKit
import SwiftUI

struct PricesView: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = PricesViewController()
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
