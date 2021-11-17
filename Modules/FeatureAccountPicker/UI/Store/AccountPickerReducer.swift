// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions

private struct UpdateSubscriptionId: Hashable {}
private struct UpdateHeaderId: Hashable {}

let accountPickerReducer = Reducer<AccountPickerState, AccountPickerAction, AccountPickerEnvironment>.combine(
    accountPickerRowReducer.forEach(
        state: \.self,
        action: /SuccessRowsAction.accountPickerRow(id:action:),
        environment: { environment in
            AccountPickerRowEnvironment(
                mainQueue: environment.mainQueue,
                updateSingleAccount: environment.updateSingleAccount,
                updateAccountGroup: environment.updateAccountGroup
            )
        }
    )
    .pullback(state: /Result.success, action: /LoadedRowsAction.success, environment: { $0 })
    .pullback(state: /LoadingState.loaded, action: /AccountPickerAction.rowsLoaded, environment: { $0 })
    .pullback(state: \.rows, action: /AccountPickerAction.self, environment: { $0 }),
    Reducer { state, action, environment in
        switch action {

        case .rowsLoaded(.success(.accountPickerRow(
            id: let id,
            action: .accountPickerRowDidTap
        ))):
            environment.rowSelected(id)
            return .none

        case .rowsLoaded(.success(.accountPickerRow(
            id: let id,
            action: .singleAccount(action: .update(balances: let balances))
        ))):
            state.fiatBalances[id] = balances.fiatBalance.value
            state.cryptoBalances[id] = balances.cryptoBalance.value
            return .none

        case .rowsLoaded(.success(.accountPickerRow(
            id: let id,
            action: .accountGroup(action: .update(balances: let balances))
        ))):
            state.fiatBalances[id] = balances.fiatBalance.value
            state.currencyCodes[id] = balances.currencyCode.value
            return .none

        case .rowsLoading:
            return .none

        case .updateRows(rows: let rows):
            state.rows = .loaded(next: .success(IdentifiedArrayOf(uniqueElements: rows)))
            return .none

        case .failedToUpdateRows:
            state.rows = .loaded(next: .failure(.testError))
            return .none

        case .updateHeader(header: let header):
            state.header = header
            return .none

        case .failedToUpdateHeader:
            return .none

        case .search(let text):
            state.searchText = text
            environment.search(text)
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
                            return .failedToUpdateRows(error)
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
                            return .failedToUpdateHeader(error)
                        }
                    }
            )

        default:
            return .none
        }
    }
)
