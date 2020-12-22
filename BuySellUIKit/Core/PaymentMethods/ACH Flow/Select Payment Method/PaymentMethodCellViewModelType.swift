//
//  PaymentMethodCellViewModelType.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 04/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources

struct PaymentMethodCellModel: Equatable {
    var items: [PaymentMethodCellViewModelItem]
}

extension PaymentMethodCellModel: SectionModelType {
    typealias Item = PaymentMethodCellViewModelItem

    init(original: PaymentMethodCellModel, items: [PaymentMethodCellViewModelItem]) {
        self = original
        self.items = items
    }
}

enum PaymentMethodCellViewModelItem: Equatable {
    case linkedCard(LinkedCardCellPresenter)
    case account(FiatCustodialBalanceViewPresenter)
    case addNew(AddNewPaymentMethodCellModel)
}
