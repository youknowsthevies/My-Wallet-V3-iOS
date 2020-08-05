//
//  TodayExtensionCellViewModel.swift
//  TodayExtension
//
//  Created by Alex McGregor on 6/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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
