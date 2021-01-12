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

protocol LinkBankFlowRootInteractable: Interactable {
    var router: LinkBankFlowRootRouting? { get set }
}

final class LinkBankFlowRootRouter: RIBs.Router<LinkBankFlowRootInteractable>,
                                    LinkBankFlowStarter,
                                    LinkBankFlowRootRouting,
                                    LinkBankSplashScreenListener {

    private var dismissFlow: (() -> Void)?

    private let presentingController: NavigationControllerAPI?
    private let splashScreenBuilder: LinkBankSplashScreenBuildable

    init(interactor: LinkBankFlowRootInteractable,
         presentingController: NavigationControllerAPI?,
         splashScreenBuilder: LinkBankSplashScreenBuildable) {
        self.presentingController = presentingController
        self.splashScreenBuilder = splashScreenBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    func route(to screen: LinkBankFlow.Screen) {
        switch screen {
        case .splash(let data):
            let router = splashScreenBuilder.build(withListener: self, data: data)
            attachChild(router)
            presentingController?.present(router.viewControllable.uiviewController, animated: true, completion: nil)
        }
    }

    func closeFlow() {
        dismissFlow?()
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
