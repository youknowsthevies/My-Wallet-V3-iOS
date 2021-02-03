//
//  PairPageBuilder.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 01/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol TargetSelectionBuildable {
    func build(withListener listener: TargetSelectionPageListener) -> TargetSelectionPageRouting
}

final class TargetSelectionPageBuilder: TargetSelectionBuildable {

    func build(withListener listener: TargetSelectionPageListener) -> TargetSelectionPageRouting {
        let viewController = TargetSelectionViewController(shouldOverrideNavigationEffects: false)
        let interactor = TargetSelectionPageInteractor(presenter: viewController)
        interactor.listener = listener
        return TargetSelectionPageRouter(interactor: interactor, viewController: viewController)
    }
}
