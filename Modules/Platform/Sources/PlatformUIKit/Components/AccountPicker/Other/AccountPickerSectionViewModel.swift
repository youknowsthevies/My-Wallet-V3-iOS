// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

public struct AccountPickerSectionViewModel: SectionModelType {
    public typealias Item = AccountPickerCellItem

    public var items: [Item]

    var identity: AnyHashable {
        // There's only ever one `AccountPickerSectionViewModel` section
        // so it must be a static string for an identifier.
        "AccountPickerSectionViewModel"
    }

    public init(original: AccountPickerSectionViewModel, items: [Item]) {
        self.init(items: items)
    }

    init(items: [Item]) {
        self.items = items
    }
}
