//
//  SwapRootViewController.swift
//  TransactionUIKit
//
//  Created by Paulo on 01/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformUIKit
import RIBs
import ToolKit

public protocol SwapRootViewControllable: ViewControllable {
    func replaceRoot(viewController: ViewControllable?)
    func present(viewController: ViewControllable?)
}

final class SwapRootViewController: UINavigationController, SwapRootViewControllable {

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    weak var listener: SwapRootListener?

    init(topMostViewControllerProvider: TopMostViewControllerProviding = resolve()) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { unimplemented() }

    func replaceRoot(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: true)
    }

    func present(viewController: ViewControllable?) {
        guard let viewController = viewController else {
            return
        }
        topMostViewControllerProvider.topMostViewController?
            .present(viewController.uiviewController, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.viewDidAppear()
    }
}
