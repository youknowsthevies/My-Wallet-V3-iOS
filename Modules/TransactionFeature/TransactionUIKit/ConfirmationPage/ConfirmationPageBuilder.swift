//
//  ConfirmationPageBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 29/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs
import UIKit

protocol ConfirmationPageListener: AnyObject {
    func closeFlow()
    func checkoutDidTapBack()
}

protocol ConfirmationPageBuildable {
    func build(listener: ConfirmationPageListener) -> ConfirmationPageRouter
}

final class ConfirmationPageBuilder: ConfirmationPageBuildable {
    private let transactionModel: TransactionModel
    
    init(transactionModel: TransactionModel) {
        self.transactionModel = transactionModel
    }
    
    func build(listener: ConfirmationPageListener) -> ConfirmationPageRouter {
        let detailsPresenter = ConfirmationPageDetailsPresenter()
        let viewController = DetailsScreenViewController(presenter: detailsPresenter)
        let interactor = ConfirmationPageInteractor(presenter: detailsPresenter, transactionModel: transactionModel)
        let router = ConfirmationPageRouter(interactor: interactor, viewController: viewController)
        interactor.listener = listener
        return router
    }
}

/// Conforming to ConfirmationPageViewControllable for RIB compatibility
extension DetailsScreenViewController: ViewControllable { }
