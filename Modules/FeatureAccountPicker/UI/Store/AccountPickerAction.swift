// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

enum AccountPickerAction {
    case accountPickerRow(id: AccountPickerRow.ID, action: AccountPickerRowAction)
    case update(rows: [AccountPickerRow])
    case subscribeToUpdates
    case failedToUpdate(Error)
}
