//
//  PaymentMethodRouter.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 4/28/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs
import ToolKit

protocol PaymentMethodInteractable: Interactable {
    var router: PaymentMethodRouting? { get set }
    var listener: PaymentMethodListener? { get set }
}

protocol PaymentMethodViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaymentMethodRouter: ViewableRouter<PaymentMethodInteractable, PaymentMethodViewControllable>, PaymentMethodRouting {
    
    override init(interactor: PaymentMethodInteractable, viewController: PaymentMethodViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: - PaymentMethodRouting
    
    func routeToWireTransfer() {
        unimplemented()
    }
    
    func routeToLinkedBanks() {
        unimplemented()
    }
}
