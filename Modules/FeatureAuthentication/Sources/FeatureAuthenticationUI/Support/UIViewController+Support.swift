// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIKit

extension UIViewController {
    /// We want to use `BottomSheetPresenting` here but we don't want to
    /// have to import `PlatformUIKit`, so we inject the `UIViewControllerTransitioningDelegate`.
    public func presentSupportViewFromViewController(
        _ viewController: UIViewController,
        transitioningDelegate: UIViewControllerTransitioningDelegate
    ) {
        let controller = UIHostingController<SupportView>(
            rootView: SupportView(
                store: .init(
                    initialState: .init(
                        applicationVersion: Bundle.applicationVersion ?? "",
                        bundleIdentifier: Bundle.main.bundleIdentifier ?? ""
                    ),
                    reducer: supportViewReducer,
                    environment: .default
                )
            )
        )
        controller.transitioningDelegate = transitioningDelegate
        controller.modalPresentationStyle = .custom
        viewController.present(controller, animated: true, completion: nil)
    }
}
