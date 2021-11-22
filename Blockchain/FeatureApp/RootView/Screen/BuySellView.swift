//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import SwiftUI

struct BuySellView: UIViewControllerRepresentable {

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = SegmentedViewController(
            presenter: BuySellSegmentedViewPresenter()
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
