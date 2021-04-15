//
//  UIViewController+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

extension UIViewController {
    public var isPresentedModally: Bool {
        let isModal = presentingViewController != nil
        let isNavigationControllerModal = navigationController?.presentingViewController != nil
        let isTabBarModel = tabBarController?.presentingViewController != nil
        return isModal || isNavigationControllerModal || isTabBarModel
    }
}
