import PlatformUIKit
import SwiftUI

protocol BuyButtonViewRenderer {
    func render(buyButton: BuyButtonView, isVisible: Bool)
}

extension SegmentedTabViewController: BuyButtonViewRenderer {
    private static let tagIdForBuyButton: Int = "\(BuyButtonView.self)".hash

    func render(buyButton: BuyButtonView, isVisible: Bool) {
        isVisible ? display(buyButton: buyButton) : remove(buyButton: UIHostingController(rootView: buyButton).view)
    }

    private func display(buyButton: BuyButtonView) {
        let wrappedView: UIView = UIHostingController(rootView: buyButton).view
        wrappedView.tag = SegmentedTabViewController.tagIdForBuyButton
        wrappedView.backgroundColor = .clear
        remove(buyButton: wrappedView)

        view.addSubview(wrappedView)
        wrappedView.layoutToSuperview(.bottom)
        wrappedView.layoutToSuperview(axis: .horizontal)

        segmentedViewControllers.forEach { $0.adjustInsetForBottomButton(withHeight: BuyButtonView.height) }
    }

    private func remove(buyButton: UIView) {
        segmentedViewControllers.forEach { $0.adjustInsetForBottomButton(withHeight: 0.0) }
        view.viewWithTag(SegmentedTabViewController.tagIdForBuyButton)?.removeFromSuperview()
    }
}
