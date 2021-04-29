// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

struct TodayExtensionSectionViewModel {
    let sectionType: TodayExtensionSectionType
    var items: [TodayExtensionCellViewModel]
    var identity: String {
        sectionType.rawValue
    }
}

extension TodayExtensionSectionViewModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = TodayExtensionCellViewModel
    
    init(original: TodayExtensionSectionViewModel, items: [TodayExtensionCellViewModel]) {
        self = original
        self.items = items
    }
}
