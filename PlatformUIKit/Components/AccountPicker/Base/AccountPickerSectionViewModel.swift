//
//  AccountPickerSectionViewModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources

struct AccountPickerSectionViewModel: SectionModelType {
    typealias Item = AccountPickerCellItem

    var items: [Item]

    var identity: AnyHashable {
        // There's only ever one `AccountPickerSectionViewModel` section
        // so it must be a static string for an identifier.
        "AccountPickerSectionViewModel"
    }

    init(original: AccountPickerSectionViewModel, items: [Item]) {
        self.init(items: items)
    }

    init(items: [Item]) {
        self.items = items
    }
}
