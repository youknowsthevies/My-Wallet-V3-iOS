// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import UIKit

/// Acts as a container for the Home screen
final class LoggedInHostingController: UIViewController {
    let store: Store<LoggedIn.State, LoggedIn.Action>

    private var cancellables: Set<AnyCancellable> = []

    /// The controllers
    private var sideMenuViewController: SideMenuViewController?
    private var tabControllerManager: TabControllerManager?
    private var slidingViewController: ECSlidingViewController?

    init(store: Store<LoggedIn.State, LoggedIn.Action>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let sideMenu = sideMenuProvider()
        let tabController = tabControllerProvider()
        let slidingViewController = slidingControllerProvider(sideMenuController: sideMenu, tabController: tabController)
        add(child: slidingViewController)
        self.slidingViewController = slidingViewController
        self.sideMenuViewController = sideMenu
        self.tabControllerManager = tabController
    }

    // MARK: Private

    private func sideMenuProvider() -> SideMenuViewController {
        let sideMenuController = SideMenuViewController.makeFromStoryboard()
        sideMenuController.delegate = self
        return sideMenuController
    }

    private func tabControllerProvider() -> TabControllerManager {
        TabControllerManager()
    }

    private func slidingControllerProvider(sideMenuController: SideMenuViewController?,
                                           tabController: TabControllerManager?) -> ECSlidingViewController {
        let viewController = ECSlidingViewController()
        // Assign the required controllers
        viewController.underLeftViewController = sideMenuController
        viewController.topViewController = tabController?.tabViewController
        // Configure the main controller
        tabController?.tabViewController.sideMenuGesture = viewController.panGesture
        tabController?.tabViewController.loadViewIfNeeded()
        // Configure side menu controller
        sideMenuController?.peekPadding = viewController.anchorRightPeekAmount
        // Show dashboard as the default screen
        tabController?.showDashboard()
        return viewController
    }
}

extension LoggedInHostingController: SideMenuViewControllerDelegate {
    func sideMenuViewController(_ viewController: SideMenuViewController, didTapOn item: SideMenuItem) {
        // TODO: Handle showing the various items sent by the SideMenuViewController
    }
}
