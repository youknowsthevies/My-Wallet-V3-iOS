//
//  NewSwapBuilder.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol NewSwapBuildable: Buildable {
    func build(withListener listener: NewSwapListener) -> NewSwapRouting
}

final class NewSwapBuilder: NewSwapBuildable {

    func build(withListener listener: NewSwapListener) -> NewSwapRouting {
        let viewController = NewSwapViewController()
        let interactor = NewSwapInteractor(presenter: viewController)
        interactor.listener = listener
        return NewSwapRouter(interactor: interactor, viewController: viewController)
    }
}
