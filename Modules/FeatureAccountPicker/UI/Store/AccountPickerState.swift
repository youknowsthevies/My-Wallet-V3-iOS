import ComposableArchitecture
import ComposableArchitectureExtensions
import SwiftUI

enum AccountPickerError: Error {
    case testError
}

struct AccountPickerState: Equatable {
    typealias RowState = LoadingState<Result<IdentifiedArrayOf<AccountPickerRow>, AccountPickerError>>

    var rows: RowState
    var header: Header

    var searchText: String?

    var fiatBalances: [AnyHashable: String]
    var cryptoBalances: [AnyHashable: String]
    var currencyCodes: [AnyHashable: String]
}
