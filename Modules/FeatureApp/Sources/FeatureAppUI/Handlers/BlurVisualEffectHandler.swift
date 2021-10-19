// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// Types adopting to `BlurVisualEffectHandlerAPI` should provide a way to apply a blur effect to the given view
public protocol BlurVisualEffectHandlerAPI {

    /// Applies a blur effect
    /// - Parameter view: A `UIView` for the effect to be applied to
    func applyEffect(on view: UIView)

    /// Removes a blur effect
    /// - Parameter view: A `UIView` for the effect to be removed from
    func removeEffect(from view: UIView)
}

final class BlurVisualEffectHandler: BlurVisualEffectHandlerAPI {

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
