// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum AppUpgradeAction: Equatable {
    case skip
}

public let appUpgradeReducer = Reducer<
    AppUpgradeState, AppUpgradeAction, Void
> { _, action, _ in
    switch action {
    case .skip:
        return .none
    }
}
