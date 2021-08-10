// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let accountPickerReducer = Reducer<AccountPickerState, AccountPickerAction, AccountPickerEnvironment>.combine(
    accountPickerRowReducer.forEach(
        state: \.rows,
        action: /AccountPickerAction.accountPickerRow(id:action:),
        environment: { _ in AccountPickerRowEnvironment() }
    ),
    Reducer { _, action, _ in
        switch action {
        case .accountPickerRow(id: let id, action: let action):
            return .none
        }
    }
)
