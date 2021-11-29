// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureWalletConnectDomain
import Localization
import UIComponentsKit
import WalletConnectSwift

struct DAppListEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let onComplete: (_ validate: Bool) -> Void
    let sessionRepository: SessionRepositoryAPI
    let router: WalletConnectRouterAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        router: WalletConnectRouterAPI,
        sessionRepository: SessionRepositoryAPI,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
        self.sessionRepository = sessionRepository
        self.router = router
    }
}

let dAppListReducer = Reducer.combine(
    Reducer<
        DAppListState,
        DAppListAction,
        DAppListEnvironment
    > { state, action, env in
        switch action {
        case .onAppear:
            return Effect(value: DAppListAction.loadSessions)
        case .loadSessions:
            return env.sessionRepository
                .retrieve()
                .catchToEffect()
                .map(DAppListAction.didReceiveSessions)
        case .didReceiveSessions(let result):
            if case .success(let sessions) = result {
                state.sessions = sessions
                state.title = String(
                    format: LocalizationConstants.WalletConnect.connectedAppsCount,
                    String(sessions.count)
                )
            }
            return .none
        case .showSessionDetails(let session):
            return env.router
                .showSessionDetails(session: session)
                .catchToEffect()
                .delay(for: .milliseconds(500), scheduler: env.mainQueue)
                .map(DAppListAction.loadSessions)
                .eraseToEffect()
        case .close:
            env.onComplete(false)
            return .none
        }
    }
)
