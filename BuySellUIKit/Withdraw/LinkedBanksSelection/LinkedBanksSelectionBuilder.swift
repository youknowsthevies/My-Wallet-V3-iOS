//
//  SelectLinkedBanksBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import UIKit

/// Provides the entry point for `SelectLinkedBanksRouter`
protocol LinkedBanksSelectionBuildable {
    func build(listener: LinkedBanksSelectionListener) -> LinkedBanksSelectionRouter
}

final class LinkedBanksSelectionBuilder: LinkedBanksSelectionBuildable {

    private let currency: FiatCurrency
    
    public init(currency: FiatCurrency) {
        self.currency = currency
    }

    func build(listener: LinkedBanksSelectionListener) -> LinkedBanksSelectionRouter {
        let viewController = LinkedBanksSelectionViewController()
        let interactor = LinkedBanksSelectionInteractor(presenter: viewController,
                                                        currency: currency)
        interactor.listener = listener
        let addNewBankAccountBuilder = AddNewBankAccountBuilder(currency: currency,
                                                                isOriginDeposit: false)
        let router = LinkedBanksSelectionRouter(interactor: interactor,
                                                viewController: viewController,
                                                addNewBankBuilder: addNewBankAccountBuilder)
        return router
    }

}
