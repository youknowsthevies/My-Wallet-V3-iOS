//
//  WalletPickerSectionViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources

struct WalletPickerSectionViewModel {
    var items: [WalletPickerCellItem]
    var identity: AnyHashable {
        // There's only ever one `WalletPickerSectionViewModel`  section
        // so it must be a static string for an identifier.
        "WalletPickerSectionViewModel"
    }
}

extension WalletPickerSectionViewModel: SectionModelType {
    typealias Item = WalletPickerCellItem
    
    init(original: WalletPickerSectionViewModel, items: [WalletPickerCellItem]) {
        self = original
        self.items = items
    }
}

