//
//  DepositRootRouter.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 4/28/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import ToolKit

protocol DepositRootInteractable: Interactable,
                                  TransactionFlowListener,
                                  PaymentMethodListener,
                                  LinkedBanksListener {
    
    var router: DepositRootRouting? { get set }
    var listener: DepositRootListener? { get set }
}

protocol DepositRootViewControllable: ViewControllable {
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func present(viewController: ViewControllable?)
    func present(viewController: ViewControllable?, animated: Bool)
}

final class DepositRootRouter: ViewableRouter<DepositRootInteractable, DepositRootViewControllable>, DepositRootRouting {
    
    // MARK: - Private Properties
    
    private var transactionRouter: ViewableRouting?
    
    // MARK: - Init
    
    override init(interactor: DepositRootInteractable, viewController: DepositRootViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: - DepositRootRouting
    
    func routeToDepositLanding() {
        let builder = PaymentMethodBuilder()
        let router = builder.build(withListener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable, animated: false)
    }
    
    func routeToDeposit(sourceAccount: FiatAccount) {
        unimplemented()
        // TODO: `build` function should take a `BlockchainAccount`
        
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .deposit,
            // TODO: This will always fail until `sourceAccount` takes a `BlockchainAccount`
            sourceAccount: sourceAccount as! CryptoAccount,
            target: nil
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable
            attachChild(router)
            viewController.present(viewController: viewControllable)
        }
    }
    
    func dismissTransactionFlow() {
        guard let router = transactionRouter else { return }
        detachChild(router)
        transactionRouter = nil
    }
}
