//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import SwiftUI

struct BuySellView: UIViewControllerRepresentable {

    var selectedSegment: Int = 0

    func updateUIViewController(_ uiViewController: SegmentedViewController, context: Context) {
        uiViewController.selectSegment(selectedSegment)
    }

    func makeUIViewController(context: Context) -> SegmentedViewController {
        let viewController = SegmentedViewController(
            presenter: BuySellSegmentedViewPresenter()
        )
        viewController.automaticallyApplyNavigationBarStyle = false
        return viewController
    }
}
