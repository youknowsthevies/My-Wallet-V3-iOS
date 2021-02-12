//
//  LinkBankFlowRootRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 10/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

public protocol LinkBankFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow(flowDismissed: @escaping () -> Void)
}

protocol LinkBankFlowRootInteractable: Interactable,
                                       LinkBankSplashScreenListener,
                                       YodleeScreenListener,
                                       LinkBankFailureScreenListener {
    var router: LinkBankFlowRootRouting? { get set }
}

final class LinkBankFlowRootRouter: RIBs.Router<LinkBankFlowRootInteractable>,
                                    LinkBankFlowStarter,
                                    LinkBankFlowRootRouting {

    private var dismissFlow: (() -> Void)?

    private let stateService: StateServiceAPI
    private let presentingController: NavigationControllerAPI?
    private let splashScreenBuilder: LinkBankSplashScreenBuildable
    private let yodleeScreenBuilder: YodleeScreenBuildable
    private let failureScreenBuilder: LinkBankFailureScreenBuildable

    private var navigationController: UINavigationController?

    init(interactor: LinkBankFlowRootInteractable,
         stateService: StateServiceAPI,
         presentingController: NavigationControllerAPI?,
         splashScreenBuilder: LinkBankSplashScreenBuildable,
         yodleeScreenBuilder: YodleeScreenBuildable,
         failureScreenBuilder: LinkBankFailureScreenBuildable) {
        self.stateService = stateService
        self.presentingController = presentingController
        self.splashScreenBuilder = splashScreenBuilder
        self.yodleeScreenBuilder = yodleeScreenBuilder
        self.failureScreenBuilder = failureScreenBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    func route(to screen: LinkBankFlow.Screen) {
        switch screen {
        case .splash(let data):
            detachCurrentChild() // in case of a failure we need to detatch the current child
            let router = splashScreenBuilder.build(withListener: interactor, data: data)
            attachChild(router)
            let navigationController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
            presentingController?.present(navigationController, animated: true, completion: nil)
            self.navigationController = navigationController
        case .yodlee(let data):
            let router = yodleeScreenBuilder.build(withListener: interactor, data: data)
            attachChild(router)
            navigationController?.pushViewController(router.viewControllable.uiviewController, animated: true)
        case .failure:
            let router = failureScreenBuilder.build(withListener: interactor)
            attachChild(router)
            presentingController?.present(router.viewControllable.uiviewController, animated: true, completion: nil)
        }
    }

    func closeFailureScreen() {
        detachCurrentChild()
        presentingController?.dismiss(animated: true, completion: nil)
    }

    func returnToSplashScreen() {
        detachCurrentChild()
    }

    func closeFlow() {
        stateService.previousRelay.accept(())
        presentingController?.dismiss(animated: true, completion: { [weak self] in
            self?.dismissFlow?()
        })
    }

    // MARK: - LinkBankFlowStarter
    func startFlow(flowDismissed: @escaping () -> Void) {
        dismissFlow = flowDismissed
        interactable.activate()
        load()
    }

    // MARK: - Private methods

    func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }
}
