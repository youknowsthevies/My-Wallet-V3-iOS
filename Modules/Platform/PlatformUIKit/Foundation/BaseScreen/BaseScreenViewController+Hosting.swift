// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
import UIKit

extension UIViewController {

    /// A simple extension on `UIViewController` to be able to present `SwiftUI.View`s.
    /// - Remark: See also `UIViewController.present(view:,inNavigationController:)`
    /// - Parameters:
    ///     - swiftUIView: The `SwiftUI.View` to be hosted by the controller.
    public func configure<Content: View>(with swiftUIView: Content) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.constraint(edgesTo: view)
    }

    /// Allows any `UIViewController` to present a `UIViewController` with an embedded `SwiftUI.View`, optionally wrapped in a `UINavigationController`
    /// - Parameters:
    ///   - view: The `SwiftUI.View` to be presented.
    ///   - inNavigationController: If `true` the `UIViewController` hosting the `view` is wrapped within a `UINavigationController`.
    public func present<Content: View>(view: Content, inNavigationController: Bool = true) {
        let hostViewController = UIViewController()
        hostViewController.configure(with: view)
        hostViewController.isModalInPresentation = true
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
