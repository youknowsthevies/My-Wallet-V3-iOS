// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public extension UIView {
    
    @discardableResult
    func constraint(edgesTo other: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        let constraints = [
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leftAnchor.constraint(equalTo: other.leftAnchor, constant: insets.left),
            rightAnchor.constraint(equalTo: other.rightAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ]
        activate(constraints)
        return constraints
    }
    
    private func activate(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}
