// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum WalletUpgrade {
    public enum Action: Equatable {
        case begin
        case completed
    }

    /// intentionally left empty
    public struct State: Equatable {}
    /// intentionally left empty
    public struct Environment {}
}

/// This is tiny, :apologies:, the logic can be extracted out of the Interactor/Presenter of the current WalletUpgrade implementation
/// but having this here might force us to refactor the current implementation.
let walletUpgradeReducer = Reducer<WalletUpgrade.State, WalletUpgrade.Action, WalletUpgrade.Environment> { _, action, _ in
    switch action {
    case .begin:
        return .none
    case .completed:
        return .none
    }
}
