// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformKit

struct UnlockTradingState: Equatable {

    enum UpgradePath: Hashable {
        case basic, verified
    }

    let currentUserTier: KYC.Tier
    @BindableState var selectedUpgradePath: UpgradePath = .verified
}

enum UnlockTradingAction: Equatable, BindableAction {
    case binding(BindingAction<UnlockTradingState>)
    case closeButtonTapped
    case unlockButtonTapped(KYC.Tier)
}

struct UnlockTradingEnvironment {
    let dismiss: () -> Void
    let unlock: (KYC.Tier) -> Void
}

let unlockTradingReducer = Reducer<
    UnlockTradingState,
    UnlockTradingAction,
    UnlockTradingEnvironment
> { _, action, environment in
    switch action {
    case .closeButtonTapped:
        return .fireAndForget {
            environment.dismiss()
        }

    case .unlockButtonTapped(let requiredTier):
        return .fireAndForget {
            environment.unlock(requiredTier)
        }

    case .binding:
        return .none
    }
}
.binding()
