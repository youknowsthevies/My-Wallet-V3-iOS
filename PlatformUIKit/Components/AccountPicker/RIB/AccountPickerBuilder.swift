//
//  AccountPickerBuilder.swift
//  PlatformUIKit
//
//  Created by Paulo on 21/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs

public typealias AccountPickerDidSelect = (BlockchainAccount) -> Void

public protocol AccountPickerBuildable: Buildable {
    func build(withDidSelect didSelect: @escaping AccountPickerDidSelect) -> AccountPickerRouting
}

public final class AccountPickerBuilder: AccountPickerBuildable {

    // MARK: - Private Properties

    private let action: AssetAction
    private let singleAccountsOnly: Bool
    private let sourceAccount: CryptoAccount?
    private let navigationModel: ScreenNavigationModel
    private let headerModel: AccountPickerHeaderType

    // MARK: - Init

    public init(singleAccountsOnly: Bool,
                action: AssetAction,
                sourceAccount: CryptoAccount? = nil,
                navigationModel: ScreenNavigationModel,
                headerModel: AccountPickerHeaderType) {
        self.action = action
        self.singleAccountsOnly = singleAccountsOnly
        self.sourceAccount = sourceAccount
        self.navigationModel = navigationModel
        self.headerModel = headerModel
    }

    // MARK: - Public Methods

    public func build(withDidSelect didSelect: @escaping AccountPickerDidSelect) -> AccountPickerRouting {
        let viewController = AccountPickerViewController()
        let presenter = AccountPickerPresenter(
            viewController: viewController,
            action: action,
            navigationModel: navigationModel,
            headerModel: headerModel
        )
        let interactor = AccountPickerInteractor(
            presenter: presenter,
            singleAccountsOnly: singleAccountsOnly,
            sourceAccount: sourceAccount,
            action: action,
            didSelect: didSelect
        )
        return AccountPickerRouter(interactor: interactor, viewController: viewController)
    }
}
