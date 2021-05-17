// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources
import RxSwift

struct TodayExtensionCellViewModel {

    let cellType: TodayExtensionSectionType.CellType

    init(cellType: TodayExtensionSectionType.CellType) {
        self.cellType = cellType
    }
}

extension TodayExtensionCellViewModel: IdentifiableType, Equatable {
    var identity: String {
        cellType.identity
    }

    typealias Identity = String

    static func == (lhs: TodayExtensionCellViewModel, rhs: TodayExtensionCellViewModel) -> Bool {
        lhs.cellType == rhs.cellType
    }
}
