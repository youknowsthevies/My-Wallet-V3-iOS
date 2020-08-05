//
//  TodayExtensionSectionViewModel.swift
//  TodayExtension
//
//  Created by Alex McGregor on 6/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
