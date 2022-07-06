// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum ReferFriendModule {}

extension ReferFriendModule {
    public static var reducer: Reducer<ReferFriendState, ReferFriendAction, ReferFriendEnvironment> {
        .init { state, action, environment in
            switch action {
            case .onAppear:
                return .none

            case .onShareTapped:
                state.isShareModalPresented = true
                return .none

            case .onShowRefferalTapped:
                state.isShowReferralViewPresented = true
                return .none

            case .onCopyReturn:
                state.codeIsCopied = false
                return .none

            case .binding:
                return .none

            case .onCopyTapped:
                state.codeIsCopied = true

                return Effect(value: .onCopyReturn)
                    .delay(
                        for: 2,
                        scheduler: environment.mainQueue
                    )
                    .eraseToEffect()
            }
        }
        .binding()
    }
}
