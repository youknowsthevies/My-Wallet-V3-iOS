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

    private let singleAccountsOnly: Bool
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let headerModel: AccountPickerHeaderType

    // MARK: - Init

    public init(singleAccountsOnly: Bool,
                action: AssetAction,
                navigationModel: ScreenNavigationModel,
                headerModel: AccountPickerHeaderType) {
        self.singleAccountsOnly = singleAccountsOnly
        self.action = action
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
            action: action,
            didSelect: didSelect
        )
        return AccountPickerRouter(interactor: interactor, viewController: viewController)
    }
}
