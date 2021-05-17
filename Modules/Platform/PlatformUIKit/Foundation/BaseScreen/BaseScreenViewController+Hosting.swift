// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import UIKit

extension BaseScreenViewController {

    /// A simple extension on `BaseScreenViewController` to be able to present `SwiftUI.View`s.
    /// - Remark: See also `UIViewController.present(view:,inNavigationController:)`
    /// - Parameters:
    ///     - swiftUIView: The `SwiftUI.View` to be hosted by the controller.
    public func configure<Content: View>(with swiftUIView: Content) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.constraint(edgesTo: view)
    }
}

extension UIViewController {

    /// Allows any `UIViewController` to present a `BaseScreenViewController` with an embedded `SwiftUI.View`, optionally wrapped in a `UINavigationController`
    /// - Parameters:
    ///   - view: The `SwiftUI.View` to be presented.
    ///   - inNavigationController: If `true` the `BaseScreenViewController` hosting the `view` is wrapped within a `UINavigationController`.
    public func present<Content: View>(view: Content, inNavigationController: Bool = true) {
        let hostViewController = BaseScreenViewController()
        hostViewController.configure(with: view)
        hostViewController.barStyle = .darkContent(ignoresStatusBar: true, isTranslucent: false, background: .white)
        hostViewController.trailingButtonStyle = .close
        let destination: UIViewController
        if inNavigationController {
            let navigationController = UINavigationController(rootViewController: hostViewController)
            navigationController.navigationBar.tintColor = .linkableText
            destination = navigationController
        } else {
            destination = hostViewController
        }
        present(destination, animated: true, completion: nil)
    }
}
