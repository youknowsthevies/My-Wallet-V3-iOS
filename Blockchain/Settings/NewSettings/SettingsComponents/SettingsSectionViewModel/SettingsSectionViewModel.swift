//
//  SettingsSectionViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources
import ToolKit

struct SettingsSectionViewModel {
    let sectionType: SettingsSectionType
    var items: [SettingsCellViewModel]
    var identity: AnyHashable {
        sectionType.rawValue
    }
}

extension SettingsSectionViewModel: AnimatableSectionModelType {
    typealias Item = SettingsCellViewModel
    
    init(original: SettingsSectionViewModel, items: [SettingsCellViewModel]) {
        self = original
        self.items = items
    }
}
