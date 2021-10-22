// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

enum AccountPickerAction {
    case rowsLoaded(LoadedRowsAction)
    case rowsLoading(LoadingRowsAction)

    case subscribeToUpdates

    case updateRows(_ rows: [AccountPickerRow])
    case failedToUpdateRows(Error)

    case updateHeader(_ header: Header)
    case failedToUpdateHeader(Error)
}

enum LoadedRowsAction {
    case success(SuccessRowsAction)
    case failure(FailureRowsAction)
}

enum LoadingRowsAction {}

enum SuccessRowsAction {
    case accountPickerRow(id: AccountPickerRow.ID, action: AccountPickerRowAction)
}

enum FailureRowsAction {}
