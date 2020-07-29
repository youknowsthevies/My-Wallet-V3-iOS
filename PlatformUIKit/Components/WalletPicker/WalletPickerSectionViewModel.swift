//
//  WalletPickerSectionViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources

public struct WalletPickerSectionViewModel: SectionModelType {
    public typealias Item = WalletPickerCellItem

    public var items: [Item]

    var identity: AnyHashable {
        // There's only ever one `WalletPickerSectionViewModel`  section
        // so it must be a static string for an identifier.
        "WalletPickerSectionViewModel"
    }

    public init(original: WalletPickerSectionViewModel, items: [WalletPickerCellItem]) {
        self.init(items: items)
    }

    public init(items: [WalletPickerCellItem]) {
        self.items = items
    }
}

