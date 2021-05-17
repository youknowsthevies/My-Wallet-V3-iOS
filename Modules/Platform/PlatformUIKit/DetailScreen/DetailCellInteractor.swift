// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum DetailCellInteractor {
    case balance(CurrentBalanceCellInteractor)
    case item(LineItem)

    public enum LineItem {
        case `default`(DefaultLineItemCellInteractor)
    }
}
