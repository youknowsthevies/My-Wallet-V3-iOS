//
//  NavigationControllerAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol NavigationControllerAPI: ViewControllerAPI {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    
    @discardableResult
    func popViewController(animated: Bool) -> UIViewController?
    func popToRootViewControllerAnimated(animated: Bool)
    
    var viewControllers: [UIViewController] { get set }
    
    var viewControllersCount: Int { get }
}

extension UINavigationController: NavigationControllerAPI {
    public func popToRootViewControllerAnimated(animated: Bool) {
        self.popToRootViewController(animated: true)
    }
    public var viewControllersCount: Int { viewControllers.count }
}
