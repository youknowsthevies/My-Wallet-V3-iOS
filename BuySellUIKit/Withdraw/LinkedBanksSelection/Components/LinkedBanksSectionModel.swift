//
//  LinkedBanksSectionModel.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 06/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources

struct LinkedBanksSectionModel: Equatable {
    var items: [LinkedBanksSectionItem]
}

extension LinkedBanksSectionModel: SectionModelType {
    typealias Item = LinkedBanksSectionItem

    init(original: LinkedBanksSectionModel, items: [LinkedBanksSectionItem]) {
        self = original
        self.items = items
    }
}

enum LinkedBanksSectionItem: Equatable {
    case linkedBank(LinkedBankViewModel)
    case addNewBank(AddBankCellModel)
}
