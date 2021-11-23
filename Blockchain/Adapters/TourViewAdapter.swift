// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationUI
import FeatureTourUI
import Localization
import SwiftUI

public struct TourViewAdapter: View {

    private let store: Store<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        let viewStore = ViewStore(store)
        tourView = TourView(
            environment: TourEnvironment(
                createAccountAction: { viewStore.send(.enter(into: .createWallet)) },
                restoreAction: { viewStore.send(.enter(into: .restoreWallet)) },
                logInAction: { viewStore.send(.enter(into: .emailLogin)) }
            )
        )
    }

    private let tourView: TourView

    public var body: some View {
        WithViewStore(self.store) { _ in
            tourView
                .navigationRoute(in: store)
        }
    }

    @ViewBuilder private func makeContent(_ viewStore: ViewStore<WelcomeState, WelcomeAction>) -> some View {
        switch viewStore.route?.route {
        case .createWallet:
            makeCreateWalletView(viewStore)
        case .emailLogin:
            makeEmailLoginView()
        case .restoreWallet:
            makeSeedPhraseView(viewStore)
        case .manualLogin:
            makeManualLoginView(viewStore)
        case .secondPassword:
            makeSecondPasswordNoticeView()
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func makeCreateWalletView(_ viewStore: ViewStore<WelcomeState, WelcomeAction>) -> some View {
        IfLetStore(
            store.scope(
                state: \.createWalletState,
                action: WelcomeAction.createWallet
            ),
            then: { store in
                NavigationView {
                    CreateAccountView(store: store)
                        .trailingNavigationButton(.close) {
                            viewStore.send(.createWallet(.closeButtonTapped))
                        }
                }
            }
        )
    }

    @ViewBuilder private func makeManualLoginView(_ viewStore: ViewStore<WelcomeState, WelcomeAction>) -> some View {
        IfLetStore(
            store.scope(
                state: \.manualCredentialsState,
                action: WelcomeAction.manualPairing
            ),
            then: { store in
                NavigationView {
                    CredentialsView(
                        context: .manualPairing,
                        store: store
                    )
                    .trailingNavigationButton(.close) {
                        viewStore.send(.manualPairing(.closeButtonTapped))
                    }
                    .whiteNavigationBarStyle()
                    .navigationTitle(
                        LocalizationConstants.FeatureAuthentication.Welcome.Button.manualPairing
                    )
                }
            }
        )
    }

    @ViewBuilder private func makeEmailLoginView() -> some View {
        IfLetStore(
            store.scope(
                state: \.emailLoginState,
                action: WelcomeAction.emailLogin
            ),
            then: EmailLoginView.init(store:)
        )
    }

    @ViewBuilder private func makeSeedPhraseView(_ viewStore: ViewStore<WelcomeState, WelcomeAction>) -> some View {
        IfLetStore(
            store.scope(
                state: \.restoreWalletState,
                action: WelcomeAction.restoreWallet
            ),
            then: { store in
                NavigationView {
                    SeedPhraseView(store: store)
                        .trailingNavigationButton(.close) {
                            viewStore.send(.restoreWallet(.closeButtonTapped))
                        }
                        .whiteNavigationBarStyle()
                        .hideBackButtonTitle()
                }
            }
        )
    }

    @ViewBuilder private func makeSecondPasswordNoticeView() -> some View {
        IfLetStore(
            store.scope(
                state: \.secondPasswordNoticeState,
                action: WelcomeAction.secondPasswordNotice
            ),
            then: { store in
                NavigationView {
                    SecondPasswordNoticeView(store: store)
                }
            }
        )
    }
}
