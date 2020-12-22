//
//  ACHFlowRootRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

protocol ACHFlowRootInteractable: Interactable, SelectPaymentMethodListener {
    var router: ACHFlowRootRouting? { get set }
    var listener: ACHFlowRootListener? { get set }
}

public protocol ACHFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow(flowDismissed: @escaping () -> Void)
}

protocol ACHFlowRootViewControllable: ViewControllable {
    // Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
}

final class ACHFlowRootRouter: RIBs.Router<ACHFlowRootInteractable>,
                               ACHFlowRootRouting,
                               ACHFlowStarter {

    private let navigation: RootNavigatable
    private let selectPaymentMethodBuilder: SelectPaymentMethodBuildable

    private var dismissFlow: (() -> Void)?

    init(interactor: ACHFlowRootInteractable,
         navigation: RootNavigatable,
         selectPaymentMethodBuilder: SelectPaymentMethodBuildable) {
        self.navigation = navigation
        self.selectPaymentMethodBuilder = selectPaymentMethodBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: - ACHFlowRootRouting

    func route(to screen: ACHFlow.Screen) {
        switch screen {
        case .selectMethod:
            let router = selectPaymentMethodBuilder.build(listener: interactor)
            attachChild(router)
            navigation.set(root: router.viewControllable)
        case .addPaymentMethod:
            break
        }
    }

    func closeFlow() {
        dismissFlow?()
    }

    // MARK: - ACHFlowStarter

    public func startFlow(flowDismissed: @escaping () -> Void) {
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
