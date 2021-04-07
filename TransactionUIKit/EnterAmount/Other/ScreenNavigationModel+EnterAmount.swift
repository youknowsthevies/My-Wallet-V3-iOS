//
//  ScreenNavigationModel+EnterAmount.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 06/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

extension ScreenNavigationModel {
    enum EnterAmount { }
}

extension ScreenNavigationModel.EnterAmount {
    public static func navigation(allowsBackButton: Bool) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: allowsBackButton ? .back : .none,
            trailingButton: .close,
            titleViewStyle: .none, // will be assigned later through the DisplayBunde of EnterAmountScreen
            barStyle: .darkContent()
        )
    }
}
