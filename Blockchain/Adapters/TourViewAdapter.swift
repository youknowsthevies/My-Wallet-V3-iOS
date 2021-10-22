// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationUI
import FeatureTourUI
import SwiftUI

public struct TourViewAdapter: View {

    private let store: Store<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        let viewStore = ViewStore(store)
        tourView = TourView(
            environment: TourEnvironment(
                createAccountAction: { viewStore.send(.presentScreenFlow(.createWalletScreen)) },
                restoreAction: { viewStore.send(.presentScreenFlow(.restoreWalletScreen)) },
                logInAction: { viewStore.send(.presentScreenFlow(.emailLoginScreen)) }
            )
        )
    }

    private let tourView: TourView

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            tourView
                .sheet(
                    isPresented: .constant(
                        viewStore.screenFlow == .emailLoginScreen
                            || viewStore.screenFlow == .restoreWalletScreen
                            || viewStore.screenFlow == .manualLoginScreen
                            || viewStore.modals == .secondPasswordNoticeScreen
                    ),
                    onDismiss: {
                        if viewStore.screenFlow == .emailLoginScreen {
                            viewStore.send(.presentScreenFlow(.welcomeScreen))
                        } else if viewStore.modals == .secondPasswordNoticeScreen {
                            viewStore.send(.modalDismissed(.secondPasswordNoticeScreen))
                        }
                    },
                    content: {
                        makeContent(viewStore)
                    }
                )
        }
    }

    @ViewBuilder private func makeContent(_ viewStore: ViewStore<WelcomeState, WelcomeAction>) -> some View {
        if viewStore.screenFlow == .emailLoginScreen {
            makeEmailLoginView()
        } else if viewStore.screenFlow == .restoreWalletScreen {
            makeSeedPhraseView(viewStore)
        } else if viewStore.modals == .secondPasswordNoticeScreen {
            makeSecondPasswordNoticeView()
        }
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
                    SeedPhraseView(context: .restoreWallet, store: store)
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
