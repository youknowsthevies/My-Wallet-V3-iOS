//
//  ViewControllerAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol ViewControllerAPI: class {
    var presentedViewControllerAPI: ViewControllerAPI? { get }
    var navigationControllerAPI: NavigationControllerAPI? { get }
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

extension UIViewController: ViewControllerAPI {
    
    public var presentedViewControllerAPI: ViewControllerAPI? {
        presentedViewController
    }
    
    public var navigationControllerAPI: NavigationControllerAPI? {
        navigationController
    }
}
