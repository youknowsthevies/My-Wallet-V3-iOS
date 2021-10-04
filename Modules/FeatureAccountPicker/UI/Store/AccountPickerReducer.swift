// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

private struct UpdateSubscriptionId: Hashable {}
private struct UpdateHeaderId: Hashable {}

let accountPickerReducer = Reducer<AccountPickerState, AccountPickerAction, AccountPickerEnvironment>.combine(
    Reducer { state, action, environment in
        switch action {

        case .accountPickerRow(id: let id, action: .accountPickerRowDidTap):
            environment.rowSelected(id)
            return .none

        case .updateRows(rows: let rows):
            state.rows = IdentifiedArrayOf(uniqueElements: rows)
            return Effect(value: .subscribeToUpdates)

        case .updateHeader(header: let header):
            state.header = header
            return Effect(value: .subscribeToUpdates)

        case .failedToUpdate:
            return .none

        case .subscribeToUpdates:
            return .merge(
                environment.sections()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: UpdateSubscriptionId(), cancelInFlight: true)
                    .map { result in
                        switch result {
                        case .success(let rows):
                            return .updateRows(rows)
                        case .failure(let error):
                            return .failedToUpdate(error)
                        }
                    },
                environment.header()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: UpdateHeaderId(), cancelInFlight: true)
                    .map { result in
                        switch result {
                        case .success(let header):
                            return .updateHeader(header)
                        case .failure(let error):
                            return .failedToUpdate(error)
                        }
                    }
            )

        default:
            return .none
        }
    },
    accountPickerRowReducer.forEach(
        state: \.rows,
        action: /AccountPickerAction.accountPickerRow(id:action:),
        environment: { environment in
            AccountPickerRowEnvironment(
                mainQueue: environment.mainQueue,
                updateSingleAccount: environment.updateSingleAccount,
                updateAccountGroup: environment.updateAccountGroup
            )
        }
    )
)
