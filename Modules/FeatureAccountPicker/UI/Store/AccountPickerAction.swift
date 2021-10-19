// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

enum AccountPickerAction {
    case accountPickerRow(id: AccountPickerRow.ID, action: AccountPickerRowAction)
    case updateRows(_ rows: [AccountPickerRow])
    case subscribeToUpdates
    case failedToUpdate(Error)
    case updateHeader(_ header: Header)
}
