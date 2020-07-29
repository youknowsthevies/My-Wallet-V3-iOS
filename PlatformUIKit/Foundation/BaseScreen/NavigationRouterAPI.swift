//
//  NavigationRouterAPI.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay

/// Emits a command to return to the previous state
public protocol RoutingPreviousStateEmitterAPI: class {
    /// Move to the previous state
    var previousRelay: PublishRelay<Void> { get }
}

/// Emits a command to move forward to the next state
public protocol RoutingNextStateEmitterAPI: class {
    /// Move to the next state
    var nextRelay: PublishRelay<Void> { get }
}

/// Emits both previus and next state commands. Exposes a simple navigation API
public typealias RoutingStateEmitterAPI = RoutingPreviousStateEmitterAPI & RoutingNextStateEmitterAPI

public protocol NavigationRouterAPI: AnyObject {
    var navigationControllerAPI: NavigationControllerAPI? { get set }
    var topMostViewControllerProvider: TopMostViewControllerProviding! { get }
    
    func present(viewController: UIViewController, using presentationType: PresentationType)
    func present(viewController: UIViewController)
    
    func dismiss(completion: (() -> Void)?)
    func dismiss(using presentationType: PresentationType)
    func dismiss()
    
    func pop(animated: Bool)
}

public class NavigationRouter: NavigationRouterAPI {
        
    public weak var navigationControllerAPI: NavigationControllerAPI?
    public weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    
    public var defaultPresentationType: PresentationType {
        if navigationControllerAPI != nil {
            return .navigationFromCurrent
        } else {
            return .modalOverTopMost
        }
    }
    
    public var defaultDismissalType: PresentationType? {
        guard let navigationControllerAPI = navigationControllerAPI else {
            return nil
        }
        if navigationControllerAPI.viewControllersCount == 1 {
            return .modalOverTopMost
        } else {
            return .navigationFromCurrent
        }
    }
    
    public init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
    }
    
    public func present(viewController: UIViewController) {
        present(viewController: viewController, using: defaultPresentationType)
    }

    private func presentModal(viewController: UIViewController, in parent: ViewControllerAPI) {
        let navigationController = UINavigationController(rootViewController: viewController)
        DispatchQueue.main.async { [weak self] in
            parent.present(navigationController, animated: true, completion: nil)
            self?.navigationControllerAPI = navigationController
        }
    }
    
    public func present(viewController: UIViewController, using presentationType: PresentationType) {
        switch presentationType {
        case .modal(from: let parentViewController):
            presentModal(viewController: viewController, in: parentViewController)
        case .navigation(from: let originViewController):
            originViewController.navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .navigationFromCurrent:
            navigationControllerAPI?.pushViewController(viewController, animated: true)
        case .modalOverTopMost:
            if let parentViewController = topMostViewControllerProvider.topMostViewController {
                presentModal(viewController: viewController, in: parentViewController)
            }
        }
    }
    
    public func dismiss(completion: (() -> Void)?) {
        navigationControllerAPI?.dismiss(animated: true, completion: completion)
    }
    
    public func dismiss() {
        dismiss(using: defaultPresentationType)
    }
    
    public func dismiss(using presentationType: PresentationType) {
        switch presentationType {
        case .modal, .modalOverTopMost:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        case .navigation, .navigationFromCurrent:
            navigationControllerAPI?.popViewController(animated: true)
        }
    }
    
    public func pop(animated: Bool) {
        navigationControllerAPI!.popViewController(animated: true)
    }
}

