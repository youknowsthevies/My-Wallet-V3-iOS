// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureWalletConnectDomain
import UIKit
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
    let service: WalletConnectServiceAPI
    let router: WalletConnectRouterAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        service: WalletConnectServiceAPI,
        router: WalletConnectRouterAPI,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
        self.service = service
        self.router = router
    }
}

let walletConnectEventReducer = Reducer.combine(
    Reducer<
        WalletConnectEventState,
        WalletConnectEventAction,
        WalletConnectEventEnvironment
    > { state, action, env in
        switch action {
        case .accept:
            env.onComplete(true)
            return .none
        case .close:
            env.onComplete(false)
            return .none
        case .disconnect:
            env.service.disconnect(state.session)
            return Effect(value: .close)
        case .openWebsite:
            env.router.openWebsite(for: state.session.dAppInfo.peerMeta)
            return .none
        }
    }
)
