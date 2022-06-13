//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import DIKit
import FeatureAppUI
import FeatureReferralDomain
import FeatureReferralUI
import Localization
import MoneyKit
import SwiftUI
import ToolKit

struct RootViewState: Equatable, NavigationState {

    var route: RouteIntent<RootViewRoute>?

    @BindableState var tabs: OrderedSet<Tab>?
    @BindableState var tab: Tag.Reference = blockchain.ux.user.portfolio[].reference
    @BindableState var fab: FrequentActionState
    @BindableState var referralState: ReferralState
    @BindableState var buyAndSell: BuyAndSell = .init()
}

extension RootViewState {
    struct BuyAndSell: Equatable {
        var segment: Int = 0
    }

    struct FrequentActionState: Equatable {
        var isOn: Bool = false
        var animate: Bool
        var data: Data?

        struct Data: Codable, Equatable {
            var list: [FrequentAction]
            var buttons: [FrequentAction]
        }
    }

    struct ReferralState: Equatable {
        var isVisible: Bool { referral != nil }
        var isHighlighted: Bool = true
        var referral: Referral?
    }

    var hideFAB: Bool {
        guard let tabs = tabs else { return true }
        return tabs.lazy.map(\.ref.tag).doesNotContain(blockchain.ux.frequent.action[])
    }
}

enum RootViewAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<RootViewRoute>?)
    case tab(Tag.Reference)
    case frequentAction(FrequentAction)
    case binding(BindingAction<RootViewState>)
    case onReferralTap
    case onAppear
    case onDisappear
}

enum RootViewRoute: NavigationRoute {
    case account
    case QR
    case referrals

    @ViewBuilder func destination(in store: Store<RootViewState, RootViewAction>) -> some View {
        switch self {
        case .QR:
            QRCodeScannerView()
                .identity(blockchain.ux.scan.QR)
                .ignoresSafeArea()

        case .referrals:
            WithViewStore(store) { viewStore in
                if let referral = viewStore.referralState.referral {
                    ReferFriendView(store: .init(
                        initialState: .init(referralInfo: referral),
                        reducer: ReferFriendModule.reducer,
                        environment: .init(mainQueue: .main)
                    ))
                    .identity(blockchain.ux.referral)
                    .ignoresSafeArea()
                }
            }

        case .account:
            AccountView()
                .identity(blockchain.ux.user.account)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct RootViewEnvironment: PublishedEnvironment {
    var subject: PassthroughSubject<(state: RootViewState, action: RootViewAction), Never> = .init()
    var app: AppProtocol
}

let rootViewReducer = Reducer<
    RootViewState,
    RootViewAction,
    RootViewEnvironment
> { state, action, environment in
    typealias FrequentActionData = RootViewState.FrequentActionState.Data
    switch action {
    case .tab(let tab):
        state.tab = tab
        return .none
    case .frequentAction(let action):
        state.fab.isOn = false
        return .none
    case .binding(.set(\.$fab.isOn, true)):
        state.fab.animate = false
        return .none
    case .onAppear:
        return .merge(
            .fireAndForget {
                environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: true)
            },

            environment
                .app.publisher(for: blockchain.user.referral.campaign, as: Referral.self)
                .receive(on: DispatchQueue.main)
                .compactMap(\.value)
                .eraseToEffect()
                .map { .binding(.set(\.$referralState.referral, $0)) },

            environment.app.publisher(for: blockchain.ux.referral.giftbox.seen, as: Bool.self)
                .replaceError(with: false)
                .eraseToEffect()
                .map { .binding(.set(\.$referralState.isHighlighted, $0 == false)) },

            environment.app.publisher(for: blockchain.app.configuration.frequent.action, as: FrequentActionData.self)
                .compactMap(\.value)
                .eraseToEffect()
                .map { .binding(.set(\.$fab.data, $0)) },

            environment.app.publisher(for: blockchain.app.configuration.tabs, as: OrderedSet<Tab>.self)
                .compactMap(\.value)
                .eraseToEffect()
                .map { .binding(.set(\.$tabs, $0)) }
        )
    case .onDisappear:
        return .fireAndForget {
            environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: false)
        }
    case .onReferralTap:
        return .merge(
            .fireAndForget {
                environment.app.state.set(blockchain.ux.referral.giftbox.seen, to: true)
            },
            .enter(into: .referrals, context: .none)
        )

    case .route, .binding:
        return .none
    }
}
.binding()
.routing()
.published()
