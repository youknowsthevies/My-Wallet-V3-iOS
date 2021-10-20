import ComposableArchitecture
import ComposableNavigation
import SwiftUI

enum AccountPickerError: Error {
    case testError
}

struct AccountPickerState: Equatable {
    typealias RowState = LoadingState<Result<IdentifiedArrayOf<AccountPickerRow>, AccountPickerError>>

    var rows: RowState
    var header: Header
}
