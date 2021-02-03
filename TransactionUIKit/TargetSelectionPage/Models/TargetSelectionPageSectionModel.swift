//
//  PairPageSectionModel.swift
//  PlatformUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 02/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxDataSources

enum TargetSelectionPageSectionModel {
    case source(header: TargetSelectionHeaderBuilder, items: [Item])
}

extension TargetSelectionPageSectionModel: SectionModelType {
    typealias Item = TargetSelectionPageCellItem

    var items: [Item] {
        switch self {
        case .source(_, let items):
            return items
        }
    }

    var header: TargetSelectionHeaderBuilder {
        switch self {
        case .source(let header, _):
            return header
        }
    }

    init(original: TargetSelectionPageSectionModel, items: [Item]) {
        switch original {
        case .source(let header, _):
            self = .source(header: header, items: items)
        }
    }
}
