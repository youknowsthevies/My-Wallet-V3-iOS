//
//  PendingTransactionPageRouter.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 11/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol PendingTransactionPageInteractable: Interactable {
    var router: PendingTransactionPageRouting? { get set }
    var listener: PendingTransactionPageListener? { get set }
}

protocol PendingTransactionPageViewControllable: ViewControllable {
}

final class PendingTransactionPageRouter: ViewableRouter<PendingTransactionPageInteractable, PendingTransactionPageViewControllable>,
                                          PendingTransactionPageRouting {

    init(interactor: PendingTransactionPageInteractor,
         viewController: PendingTransactionPageViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
