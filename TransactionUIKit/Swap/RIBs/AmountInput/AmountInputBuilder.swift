//
//  AmountInputBuilder.swift
//  TransactionUIKit
//
//  Created by Paulo on 12/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs

// MARK: - Builder

protocol AmountInputBuildable: Buildable {
    func build(withListener listener: AmountInputListener) -> AmountInputRouting
}

final class AmountInputBuilder: AmountInputBuildable {

    let pair: (CurrencyType, CurrencyType)

    init(pair: (CurrencyType, CurrencyType)) {
        self.pair = pair
    }

    func build(withListener listener: AmountInputListener) -> AmountInputRouting {
        let viewController = AmountInputViewController()
        let interactor = AmountInputInteractor(pair: pair, presenter: viewController)
        interactor.listener = listener
        return AmountInputRouter(interactor: interactor, viewController: viewController)
    }
}
