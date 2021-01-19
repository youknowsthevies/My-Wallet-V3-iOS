//
//  TransactionFlowBuilder.swift
//  TransactionUIKit
//
//  Created by Paulo on 19/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs

// MARK: - Builder

protocol TransactionFlowBuildable: Buildable {
    func build(withListener listener: TransactionFlowListener,
               action: AssetAction,
               sourceAccount: CryptoAccount?,
               target: TransactionTarget?) -> ViewableRouting
}

final class TransactionFlowBuilder: TransactionFlowBuildable {

    func build(withListener listener: TransactionFlowListener,
               action: AssetAction,
               sourceAccount: CryptoAccount?,
               target: TransactionTarget?) -> ViewableRouting {

        // MARK: TransactionModel
        let transactionInteractor = TransactionInteractor()
        let transactionModel = TransactionModel(transactionInteractor: transactionInteractor)

        // MARK: TransactionFlow

        let viewController = TransactionFlowViewController()

        let interactor = TransactionFlowInteractor(
            transactionModel: transactionModel,
            action: action,
            sourceAccount: sourceAccount,
            target: target,
            presenter: viewController
        )
        interactor.listener = listener

        return TransactionFlowRouter(
            interactor: interactor,
            viewController: viewController
        )
    }
}
