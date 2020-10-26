//
//  SwapRootViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

public protocol SwapRootViewControllable: ViewControllable {
    func replaceRoot(viewController: ViewControllable?)
    func push(viewController: ViewControllable?)
}

final class SwapRootViewController: UINavigationController, SwapRootViewControllable {

    weak var listener: SwapRootListener?

    func replaceRoot(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: true)
    }

    func push(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        pushViewController(viewController.uiviewController, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.viewDidAppear()
    }
}
