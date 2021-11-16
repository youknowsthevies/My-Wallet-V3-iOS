// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import SwiftUI
import UIKit

public final class HostingTableViewCell<Content: View>: UITableViewCell {
    private var hostingController: UIHostingController<Content?>?
    private var heightContraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        hostingController?.view.backgroundColor = .background
        contentView.backgroundColor = .lightBorder
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func host(_ rootView: Content, parent: UIViewController, height: CGFloat?) {
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
            hostingController.view.constraint(edgesTo: contentView, insets: .init(top: 0, left: 0, bottom: 1, right: 0))

            if let height = height, heightContraint == nil {
                heightContraint = contentView.heightAnchor.constraint(equalToConstant: height)
                heightContraint?.isActive = true
            }
        }

        if requiresControllerMove {
            hostingController.didMove(toParent: parent)
        }
    }

    public func updateRootView(height: CGFloat) {
        if heightContraint != nil {
            contentView.backgroundColor = height <= 1 ? .clear : .lightBorder
            heightContraint?.constant = height
            contentView.setNeedsLayout()
        }
    }
}
