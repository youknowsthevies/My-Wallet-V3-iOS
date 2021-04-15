//
//  DetailCellInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 8/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum DetailCellInteractor {
    case balance(CurrentBalanceCellInteractor)
    case item(LineItem)
    
    public enum LineItem {
        case `default`(DefaultLineItemCellInteractor)
    }
}
