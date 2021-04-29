// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import PlatformUIKit
import ToolKit

typealias OnModalDismissed = () -> Void

typealias OnModalResumed = () -> Void

@objc class ModalPresenter: NSObject {
    
    static let shared = ModalPresenter()
    // class function declared so that the ModalPresenter singleton can be accessed from obj-C
    @objc class func sharedInstance() -> ModalPresenter {
        ModalPresenter.shared
    }
    
    @objc private(set) var modalView: BCModalView?

    private var modalChain: [BCModalView] = []

    private var topMostView: UIView? {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.view
    }
    
    private let recorder: UIOperationRecording
    private let loadingViewPresenter: LoadingViewPresenting

    private init(recorder: UIOperationRecording = CrashlyticsRecorder(),
                 loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.recorder = recorder
        self.loadingViewPresenter = loadingViewPresenter
        super.init()
    }

    @objc func closeAllModals() {
        recorder.recordIllegalUIOperationIfNeeded()

        loadingViewPresenter.hide()
        
        WalletManager.shared.wallet.isSyncing = false

        guard let modalView = modalView else { return }
        
        modalView.endEditing(true)
        modalView.removeFromSuperview()

        let animation = CATransition()
        animation.duration = Constants.Animation.duration
        animation.type = CATransitionType.fade
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        UIApplication.shared.keyWindow?.layer.add(animation, forKey: AnimationKeys.hideModal)

        modalView.onDismiss?()
        modalView.onDismiss = nil

        self.modalView = nil

        for modalView in modalChain {
            modalView.myHolderView?.subviews.forEach { $0.removeFromSuperview() }
            modalView.myHolderView?.removeFromSuperview()
            modalView.onDismiss?()
        }

        self.modalChain.removeAll()
    }

    @objc func closeModal(withTransition transition: String) {
        recorder.recordIllegalUIOperationIfNeeded()

        guard let modalView = modalView else {
            Logger.shared.warning("Cannot close modal. modalView is nil.")
            return
        }
        
        NotificationCenter.default.post(name: Constants.NotificationKeys.modalViewDismissed, object: nil)

        modalView.removeFromSuperview()

        let animation = CATransition()
        animation.duration = Constants.Animation.duration

        // There are two types of transitions: movement based and fade in/out.
        // The movement based ones can have a subType to set which direction the movement is in.
        // In case the transition parameter is a direction, we use the MoveIn transition and the transition
        // parameter as the direction, otherwise we use the transition parameter as the transition type.
        if transition != CATransitionType.fade.rawValue {
            animation.type = CATransitionType.moveIn
            animation.subtype = CATransitionSubtype(rawValue: transition)
        } else {
            animation.type = CATransitionType(rawValue: transition)
        }
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: AnimationKeys.hideModal)

        modalView.onDismiss?()
        modalView.onDismiss = nil

        if let previousModalView = modalChain.last {
            topMostView?.addSubview(previousModalView)
            topMostView?.endEditing(true)

            modalView.onResume?()

            self.modalView = previousModalView
            self.modalChain.removeLast()
        } else {
            self.modalView = nil
        }
    }

    @objc func showModal(
        withContent content: UIView,
        closeType: ModalCloseType,
        showHeader: Bool,
        headerText: String,
        onDismiss: OnModalDismissed? = nil,
        onResume: OnModalResumed? = nil
    ) {
        recorder.recordIllegalUIOperationIfNeeded()

        // Remove the modal if we have one
        if let modalView = modalView {
            modalView.removeFromSuperview()

            if modalView.closeType != ModalCloseTypeNone {
                modalView.onDismiss?()
                modalView.onDismiss = nil
            } else {
                modalChain.append(modalView)
            }

            self.modalView = nil
        }

        // Show modal
        let modalViewToShow = BCModalView(closeType: closeType, showHeader: showHeader, headerText: headerText)
        modalViewToShow.onDismiss = onDismiss
        modalViewToShow.onResume = onResume

        onResume?()

        content.frame = CGRect(
            x: 0,
            y: 0,
            width: modalViewToShow.myHolderView?.frame.size.width ?? 0,
            height: modalViewToShow.myHolderView?.frame.size.height ?? 0
        )

        modalViewToShow.myHolderView?.addSubview(content)
        topMostView?.addSubview(modalViewToShow)
        topMostView?.endEditing(true)

        // Animate modal
        let animation = CATransition()
        animation.duration = Constants.Animation.duration

        if closeType == ModalCloseTypeBack {
            animation.type = CATransitionType.moveIn
            animation.subtype = CATransitionSubtype.fromRight
        } else {
            animation.type = CATransitionType.fade
        }

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        topMostView?.layer.add(animation, forKey: AnimationKeys.showModal)

        modalView = modalViewToShow

        UIApplication.shared.statusBarStyle = .lightContent
    }

    private struct AnimationKeys {
        static let showModal = "ShowModal"
        static let hideModal = "HideModal"
    }
}
