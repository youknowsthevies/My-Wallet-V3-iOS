// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

final class DepositRootViewController: UINavigationController, DepositRootViewControllable {
    
    // MARK: - Public Properties
    
    weak var listener: DepositRootListener?
    
    // MARK: - Private Properties
    
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    
    // MARK: - Init

    init(topMostViewControllerProvider: TopMostViewControllerProviding = resolve()) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.viewDidAppear()
    }
    
    // MARK: - DepositRootViewControllable
    
    func replaceRoot(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: animated)
    }
    
    func present(viewController: ViewControllable?) {
        present(viewController: viewController, animated: true)
    }
    
    func present(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        topMostViewControllerProvider.topMostViewController?
            .present(viewController.uiviewController, animated: animated)
    }
}
