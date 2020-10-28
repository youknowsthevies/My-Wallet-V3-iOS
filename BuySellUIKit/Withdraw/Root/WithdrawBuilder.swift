//
//  WithdrawBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import UIKit

/// Provides the entry point for `WithdrawRootRouter`
public protocol WithdrawBuildable {
    /// Builds the components for the Withdraw Flow
    ///
    ///
    /// - Returns: A tuple consisting
    ///     - `flow`: A `WithdrawFlowStarter` which allows the flow to start
    ///     - `controller`: A `UINavigationController` object which acts as the root navigation of the flow.
    func build() -> (flow: WithdrawFlowStarter, controller: UINavigationController)
}

public final class WithdrawBuilder: WithdrawBuildable {

    private let currency: FiatCurrency
    
    public init(currency: FiatCurrency) {
        self.currency = currency
    }

    public func build() -> (flow: WithdrawFlowStarter, controller: UINavigationController) {
        let rootNavigation = RootNavigation()
        let linkedBanksBuilder = LinkedBanksSelectionBuilder(currency: currency)
        let enterAmountBuilder = WithdrawAmountPageBuilder(currency: currency)
        let interactor = WithdrawRootInteractor()
        let router = WithdrawRootRouter(interactor: interactor,
                                        navigation: rootNavigation,
                                        selectBanksBuilder: linkedBanksBuilder,
                                        enterAmountBuilder: enterAmountBuilder)
        return (router, rootNavigation)
    }

}
