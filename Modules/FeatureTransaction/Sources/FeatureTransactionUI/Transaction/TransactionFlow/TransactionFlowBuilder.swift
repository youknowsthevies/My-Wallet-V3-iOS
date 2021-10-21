// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs

// MARK: - Builder

public protocol TransactionFlowBuildable: RIBs.Buildable {
    func build(
        withListener listener: TransactionFlowListener,
        action: AssetAction,
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?
    ) -> ViewableRouting
}

public final class TransactionFlowBuilder: TransactionFlowBuildable {

    public init() {}

    public func build(
        withListener listener: TransactionFlowListener,
        action: AssetAction,
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?
    ) -> ViewableRouting {

        // MARK: TransactionModel

        let transactionInteractor = TransactionInteractor()
        let transactionModel = TransactionModel(
            initialState: TransactionState(
                action: action,
                source: sourceAccount,
                destination: target
            ),
            transactionInteractor: transactionInteractor
        )

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
