//
//  PaymentMethodBuilder.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 4/28/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol PaymentMethodBuildable: Buildable {
    func build(withListener listener: PaymentMethodListener) -> PaymentMethodRouting
}

final class PaymentMethodBuilder: PaymentMethodBuildable {

    public init() { }

    func build(withListener listener: PaymentMethodListener) -> PaymentMethodRouting {
        let viewController = PaymentMethodViewController()
        let interactor = PaymentMethodInteractor()
        interactor.listener = listener
        let router = PaymentMethodRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        return router
    }
}
