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
    var identity: String {
        items.map { $0.identity }.joined()
    }
}

extension WalletPickerSectionViewModel: SectionModelType {
    typealias Identity = String
    typealias Item = WalletPickerCellItem
    
    init(original: WalletPickerSectionViewModel, items: [WalletPickerCellItem]) {
        self = original
        self.items = items
    }
}

