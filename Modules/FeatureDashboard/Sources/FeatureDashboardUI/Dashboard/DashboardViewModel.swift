// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxDataSources

struct DashboardViewModel: AnimatableSectionModelType {

    // MARK: - Types

    typealias Item = DashboardCellType
    typealias Identity = String

    // MARK: - Static Properties

    static var empty: DashboardViewModel { .init(items: []) }

    // MARK: - Properties

    let items: [Item]
    var identity: Identity {
        "DashboardViewModel"
    }

    // MARK: - Init

    init(original: DashboardViewModel, items: [Item]) {
        self.items = items
    }

    init(items: [Item]) {
        self.items = items
    }
}
