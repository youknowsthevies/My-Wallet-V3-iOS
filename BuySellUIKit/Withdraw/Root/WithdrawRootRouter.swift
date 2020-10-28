//
//  WithdrawRootRouter.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa

protocol WithdrawFlowInteractable: Interactable, LinkedBanksSelectionListener, WithdrawAmountPageListener {
    var router: WithdrawFlowRouting? { get set }
    var listener: WithdrawFlowListener? { get set }
}

public protocol WithdrawFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow(flowDismissed: @escaping () -> Void)
}

final class WithdrawRootRouter: RIBs.Router<WithdrawFlowInteractable>,
                                WithdrawFlowRouting,
                                WithdrawFlowStarter {

    private let selectBanksBuilder: LinkedBanksSelectionBuildable
    private let enterAmountBuilder: WithdrawAmountPageBuildable
    private let navigation: RootNavigatable

    private var dismissFlow: (() -> Void)?

    init(interactor: WithdrawFlowInteractable,
         navigation: RootNavigatable,
         selectBanksBuilder: LinkedBanksSelectionBuildable,
         enterAmountBuilder: WithdrawAmountPageBuildable) {
        self.navigation = navigation
        self.selectBanksBuilder = selectBanksBuilder
        self.enterAmountBuilder = enterAmountBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    public override func didLoad() {
        super.didLoad()
    }

    func routeToFlowRoot() {
        let router = selectBanksBuilder.build(listener: interactor)
        attachChild(router)
        navigation.set(root: router.viewControllable)
    }

    func routeToBankSelected(beneficiary: Beneficiary) {
        let router = enterAmountBuilder.build(listener: interactor, beneficiary: beneficiary)
        attachChild(router)
        navigation.push(controller: router.viewControllable)
    }

    func routeToCheckout(checkoutData: WithdrawalCheckoutData) {
        // TODO: Route to checkout screen
    }

    func didTapBack() {
        navigation.popController()
        detachCurrentChild()
    }

    func closeFlow() {
        navigation.dismissController(animated: true, completion: dismissFlow)
    }

    // MARK: - WithdrawFlowStarter

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
