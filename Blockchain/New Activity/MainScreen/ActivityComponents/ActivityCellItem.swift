//
//  ActivityCellItem.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxDataSources

enum ActivityCellItem: IdentifiableType {
    
    typealias Identity = String
    
    var identity: String {
        switch self {
        case .skeleton(let index):
            return "\(index)"
        case .selection(let viewModel):
            return viewModel.titleRelay.value + (viewModel.subtitleRelay.value ?? "")
        case .activity(let presenter):
            return presenter.identity
        }
    }
    
    case selection(SelectionButtonViewModel)
    case skeleton(Int)
    case activity(ActivityItemPresenter)
}

extension ActivityCellItem: Equatable {
    static func ==(lhs: ActivityCellItem, rhs: ActivityCellItem) -> Bool {
        switch (lhs, rhs) {
        case (.selection(let left), .selection(let right)):
            return left.titleRelay.value == right.titleRelay.value &&
                left.subtitleRelay.value == right.subtitleRelay.value
        case (.activity(let left), .activity(let right)):
            return left.viewModel == right.viewModel
        case (.skeleton(let left), .skeleton(let right)):
            return left == right
        default:
            return false
        }
    }
}
