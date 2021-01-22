//
//  TransactionFlowRouter.swift
//  TransactionUIKit
//
//  Created by Paulo on 19/11/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import TransactionKit

protocol TransactionFlowInteractable: Interactable,
                                      EnterAmountPageListener,
                                      ConfirmationPageListener,
                                      AccountPickerListener,
                                      PendingTransactionPageListener {
    
    var router: TransactionFlowRouting? { get set }
    var listener: TransactionFlowListener? { get set }

    func didSelectSourceAccount(account: CryptoAccount)
    func didSelectDestinationAccount(target: TransactionTarget)
}

public protocol TransactionFlowViewControllable: ViewControllable {
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func push(viewController: ViewControllable?)
    func dismiss()
    func pop()
}

final class TransactionFlowRouter: ViewableRouter<TransactionFlowInteractable, TransactionFlowViewControllable>, TransactionFlowRouting {
    
    override init(
        interactor: TransactionFlowInteractable,
        viewController: TransactionFlowViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func routeToConfirmation(transactionModel: TransactionModel) {
        let builder = ConfirmationPageBuilder(transactionModel: transactionModel)
        let router = builder.build(listener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func routeToInProgress(transactionModel: TransactionModel) {
        let builder = PendingTransactionPageBuilder()
        let router = builder.build(withListener: interactor, transactionModel: transactionModel)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func closeFlow() {
        viewController.dismiss()
    }

    func pop() {
        viewController.pop()
    }

    func didTapBack() {
        guard let child = children.last else { return }
        viewController.pop()
        detachChild(child)
    }

    func routeToSourceAccountPicker(action: AssetAction) {
        let header = AccountPickerSimpleHeaderModel(
            subtitle: TransactionFlowDescriptor.AccountPicker.sourceSubtitle(action: action)
        )
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: action
        )
        let router = builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.sourceTitle(action: action)
            ),
            headerModel: .simple(header)
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable, animated: false)
    }

    func routeToDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let header = AccountPickerSimpleHeaderModel(
            subtitle: TransactionFlowDescriptor.AccountPicker.destinationSubtitle(action: action)
        )
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(transactionModel: transactionModel),
            action: action
        )
        let router = builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.AccountPicker.navigationClose(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            ),
            headerModel: .simple(header)
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func routeToPriceInput(source: BlockchainAccount, transactionModel: TransactionModel, action: AssetAction) {
        guard let source = source as? SingleAccount else { return }
        let builder = EnterAmountPageBuilder(transactionModel: transactionModel)
        let router = builder.build(listener: interactor, sourceAccount: source, action: action)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }
}
