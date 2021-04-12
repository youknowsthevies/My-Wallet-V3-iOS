//
//  TargetSelectionPageRouter.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

protocol TargetSelectionPageInteractable: Interactable {
    var router: TargetSelectionPageRouting? { get set }
    var listener: TargetSelectionPageListener? { get set }
}

final class TargetSelectionPageRouter: ViewableRouter<TargetSelectionPageInteractable, TargetSelectionPageViewControllable>,
                                       TargetSelectionPageRouting {

    override init(interactor: TargetSelectionPageInteractable, viewController: TargetSelectionPageViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
