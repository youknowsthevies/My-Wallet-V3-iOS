// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import UIKit

public final class HostingTableViewCell<Content: View>: UITableViewCell {
    private var hostingController: UIHostingController<Content?>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hostingController?.view.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func host(_ rootView: Content, parent: UIViewController) {
        hostingController?.view.removeFromSuperview()
        hostingController?.rootView = nil
        hostingController = .init(rootView: rootView)

        guard let hostingController = hostingController else {
            return
        }
        hostingController.view.invalidateIntrinsicContentSize()
        let requiresControllerMove = hostingController.parent != parent
        if requiresControllerMove {
            parent.addChild(hostingController)
        }

        if !contentView.subviews.contains(hostingController.view) {
            contentView.addSubview(hostingController.view)
            hostingController.view.constraint(edgesTo: contentView, insets: .zero)
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parent)
        }
    }
}
