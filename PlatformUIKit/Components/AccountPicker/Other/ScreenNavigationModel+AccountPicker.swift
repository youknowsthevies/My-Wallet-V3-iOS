//
//  ScreenNavigationModel+AccountPicker.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

extension ScreenNavigationModel {
    public enum AccountPicker { }
}

extension ScreenNavigationModel.AccountPicker {

    public static let modal = ScreenNavigationModel(
        leadingButton: .none,
        trailingButton: .close,
        titleViewStyle: .text(value: LocalizationConstants.WalletPicker.title),
        barStyle: .darkContent()
    )

    public static let navigation = ScreenNavigationModel(
        leadingButton: .back,
        trailingButton: .none,
        titleViewStyle: .text(value: LocalizationConstants.WalletPicker.title),
        barStyle: .darkContent()
    )
}
