//
//  BottomButtonContainerView.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import UIKit

/// Protocol definition for a view that contains a CTA button at the bottom of it's view.
/// Conforming to this protocol will auto-adjust the CTA button whenever the keyboard
/// is presented/hidden.
public protocol BottomButtonContainerView {

    /// This is to be set equal to the original bottom constraint
    /// set on the view pinning it to the bottom of it's parent.
    var originalBottomButtonConstraint: CGFloat! { get set }

    /// Some screens may want to alter the offset of the
    /// view. This is normally set to `0` but can be set to
    /// any other value and it will be added to the keyboard's
    /// height.
    var optionalOffset: CGFloat { get set }

    var layoutConstraintBottomButton: NSLayoutConstraint! { get }
}

public extension BottomButtonContainerView where Self: UIViewController {

    /// Sets up this view so that it can respond to keyboard show/hide events.
    /// This should be called in viewDidAppear()
    func setUpBottomButtonContainerView() {
        NotificationCenter.when(UIResponder.keyboardWillShowNotification) {
            self.keyboardWillShow(with: KeyboardObserver.Payload(with: $0.userInfo))
        }
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) {
            self.keyboardWillHide(with: KeyboardObserver.Payload(with: $0.userInfo))
        }
    }

    /// Call this in deinit to remove the instance as an observer to the NotificationCenter
    func cleanUp() {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardWillShow(with payload: KeyboardObserver.Payload?) {
        guard let payload = payload else { return }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.duration)
        UIView.setAnimationCurve(payload.curve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint + payload.end.height + optionalOffset
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }

    func keyboardWillHide(with payload: KeyboardObserver.Payload?) {
        guard let payload = payload else { return }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(payload.duration)
        UIView.setAnimationCurve(payload.curve)
        layoutConstraintBottomButton.constant = originalBottomButtonConstraint
        view.layoutIfNeeded()
        UIView.commitAnimations()
    }
}
