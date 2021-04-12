//
//  PendingTransactionPageBuilder.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 11/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RIBs
import TransactionKit

// MARK: - Builder

protocol PendingTransactionPageBuildable: Buildable {
    func build(withListener listener: PendingTransactionPageListener, transactionModel: TransactionModel) -> PendingTransactionPageRouter
}

final class PendingTransactionPageBuilder: PendingTransactionPageBuildable {
    
    private let pollingService: PendingSwapCompletionServiceAPI
    
    public init(pollingService: PendingSwapCompletionServiceAPI = resolve()) {
        self.pollingService = pollingService
    }

    func build(withListener listener: PendingTransactionPageListener, transactionModel: TransactionModel) -> PendingTransactionPageRouter {
        let viewController = PendingTransactionViewController()
        let interactor = PendingTransactionPageInteractor(
            transactionModel: transactionModel,
            presenter: viewController
        )
        interactor.listener = listener
        
        return PendingTransactionPageRouter(interactor: interactor, viewController: viewController)
    }
}
