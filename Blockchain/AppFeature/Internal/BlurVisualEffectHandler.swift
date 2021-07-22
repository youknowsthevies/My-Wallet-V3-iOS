// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class BlurVisualEffectHandler {

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.alpha = 0
        return view
    }()

    func applyEffect(on view: UIView) {
        applyAnimated(on: view, shouldRemove: false)
    }

    func removeEffect(from view: UIView) {
        applyAnimated(on: view, shouldRemove: true)
    }

    private func applyAnimated(on view: UIView, shouldRemove: Bool) {
        let alpha: CGFloat = shouldRemove ? 0 : 1
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.visualEffectView.alpha = alpha
            },
            completion: { finished in
                if finished {
                    if shouldRemove {
                        self.visualEffectView.removeFromSuperview()
                    }
                }
            }
        )
    }
}
