//
//  ScreenNavigationModel+TargetSelection.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 04/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit

extension ScreenNavigationModel {
    enum TargetSelection { }
}

extension ScreenNavigationModel.TargetSelection {
    public static func navigation(title: String) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: .none,
            trailingButton: .close,
            titleViewStyle: .text(value: title),
            barStyle: .darkContent()
        )
    }
}
