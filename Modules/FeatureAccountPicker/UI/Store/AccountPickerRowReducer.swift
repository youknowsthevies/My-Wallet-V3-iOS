// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

private struct UpdateAccountId: Hashable {
    let identity: AnyHashable
}

let singleAccountReducer = Reducer<
    AccountPickerRow.SingleAccount,
    AccountPickerRowAction.SingleAccountAction,
    AccountPickerRowEnvironment
> { state, action, environment in
    switch action {
    case .update(model: let model):
        state = model
        return Effect(value: .subscribeToUpdates)

    case .failedToUpdate:
        return .none

    case .subscribeToUpdates:
        return environment.updateSingleAccount(state)?
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: UpdateAccountId(identity: state.id), cancelInFlight: true)
            .map { result in
                switch result {
                case .success(let account):
                    return .update(model: account)
                case .failure(let error):
                    return .failedToUpdate(error)
                }
            } ?? .none
    }
}

let accountGroupReducer = Reducer<
    AccountPickerRow.AccountGroup,
    AccountPickerRowAction.AccountGroupAction,
    AccountPickerRowEnvironment
> { state, action, environment in
    switch action {
    case .update(model: let model):
        state = model
        return Effect(value: .subscribeToUpdates)

    case .failedToUpdate:
        return .none

    case .subscribeToUpdates:
        return environment.updateAccountGroup(state)?
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: UpdateAccountId(identity: state.id), cancelInFlight: true)
            .map { result in
                switch result {
                case .success(let accountGroup):
                    return .update(model: accountGroup)
                case .failure(let error):
                    return .failedToUpdate(error)
                }
            } ?? .none
    }
}

let accountPickerRowReducer = Reducer<AccountPickerRow, AccountPickerRowAction, AccountPickerRowEnvironment>.combine(
    singleAccountReducer.pullback(
        state: /AccountPickerRow.singleAccount,
        action: /AccountPickerRowAction.singleAccount,
        environment: { $0 }
    ),
    accountGroupReducer.pullback(
        state: /AccountPickerRow.accountGroup,
        action: /AccountPickerRowAction.accountGroup,
        environment: { $0 }
    )
)
