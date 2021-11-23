// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import WalletConnectSwift

extension Session: Equatable {
    public static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.dAppInfo == rhs.dAppInfo
            && lhs.walletInfo == rhs.walletInfo
            && lhs.url == rhs.url
    }
}

struct WalletConnectEventEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let onComplete: (_ validate: Bool) -> Void

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
    }
}

let walletConnectEventReducer = Reducer.combine(
    Reducer<
        WalletConnectEventState,
        WalletConnectEventAction,
        WalletConnectEventEnvironment
    > { _, action, env in
        switch action {
        case .accept:
            env.onComplete(true)
            return .none
        case .close:
            env.onComplete(false)
            return .none
        }
    }
)
