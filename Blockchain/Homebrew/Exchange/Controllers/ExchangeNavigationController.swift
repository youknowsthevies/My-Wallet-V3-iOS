//
//  ExchangeNavigationController.swift
//  Blockchain
//
//  Created by kevinwu on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ExchangeNavigationController: BCNavigationController {

    var rightButton: UIButton!
    var rightButtonTappedBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        rightButton = UIButton(frame: closeButton.frame)
        rightButton.imageEdgeInsets = closeButton.imageEdgeInsets
        rightButton.contentHorizontalAlignment = closeButton.contentHorizontalAlignment

        rightButton.backgroundColor = UIColor.clear

        view.addSubview(rightButton)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        updateNavBarIfNeeded()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        updateNavBarIfNeeded()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        updateNavBarIfNeeded()
        return poppedViewController
    }

    private func updateNavBarIfNeeded() {
        guard let navigatableView = visibleViewController as? ExchangeNavigatableView else {
            return
        }
        let CTA = navigatableView.navControllerCTAType()
        closeButton.isHidden = CTA != .dismiss
        rightButton.setImage(CTA.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightButton.tintColor = navigatableView.ctaTintColor
        rightButton.isHidden = CTA.visibility.isHidden
        rightButtonTappedBlock = { [unowned self] in
            navigatableView.navControllerRightBarButtonTapped(self)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rightButton.isHidden = rightButtonTappedBlock == nil
    }

    @objc func rightButtonTapped() {
        rightButtonTappedBlock?()
    }
}
