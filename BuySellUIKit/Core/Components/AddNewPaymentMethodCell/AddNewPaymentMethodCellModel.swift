//
//  AddNewPaymentMethodCellModel.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 07/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformUIKit
import RxCocoa

final class AddNewPaymentMethodCellModel {

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.PaymentMethodSelectionScreen.NewPaymentButton

    let buttonModel: ButtonViewModel

    let tap: Signal<Void>

    init() {
        buttonModel = .secondary(with: LocalizedString.title)
        buttonModel.contentInsetRelay.accept(
            UIEdgeInsets(top: Spacing.inner,
                         left: Spacing.inner,
                         bottom: Spacing.inner,
                         right: Spacing.inner)
        )
        tap = buttonModel.tap
    }
}

extension AddNewPaymentMethodCellModel: Equatable {
    static func == (lhs: AddNewPaymentMethodCellModel, rhs: AddNewPaymentMethodCellModel) -> Bool {
        lhs === rhs
    }

}
