// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
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
    let analyticsEventRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        router: WalletConnectRouterAPI,
        sessionRepository: SessionRepositoryAPI,
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        onComplete: @escaping (_ validate: Bool) -> Void
    ) {
        self.mainQueue = mainQueue
        self.onComplete = onComplete
        self.sessionRepository = sessionRepository
        self.router = router
        self.analyticsEventRecorder = analyticsEventRecorder
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
.analytics()

// MARK: - Private

extension Reducer where
    Action == DAppListAction,
    State == DAppListState,
    Environment == DAppListEnvironment
{
    /// Helper function for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                DAppListState,
                DAppListAction,
                DAppListEnvironment
            > { _, action, env in
                switch action {
                case .onAppear:
                    return Effect.fireAndForget {
                        env
                            .analyticsEventRecorder
                            .record(event: AnalyticsEvents.New.WalletConnect.connectedDappsListViewed)
                    }
                case .showSessionDetails(let session):
                    return Effect.fireAndForget {
                        env.analyticsEventRecorder
                            .record(event: AnalyticsEvents.New.WalletConnect
                                .connectedDappClicked(
                                    appName: session.dAppInfo.peerMeta.name,
                                    origin: .appsList
                                ))
                    }
                default:
                    return .none
                }
            }
        )
    }
}
