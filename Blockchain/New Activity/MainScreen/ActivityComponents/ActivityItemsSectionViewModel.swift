//
//  ActivityItemsSectionViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/22/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources
import ToolKit

struct ActivityItemsSectionViewModel {
    var items: [ActivityCellItem]
    var identity: String {
        items.map { $0.identity }.joined()
    }
}

extension ActivityItemsSectionViewModel: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = ActivityCellItem
    
    init(original: ActivityItemsSectionViewModel, items: [ActivityCellItem]) {
        self = original
        self.items = items
    }
}
