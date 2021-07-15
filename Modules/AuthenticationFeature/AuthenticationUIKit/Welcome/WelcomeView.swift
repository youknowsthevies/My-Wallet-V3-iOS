// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias WelcomeViewString = LocalizationConstants.AuthenticationKit.Welcome

public struct WelcomeView: View {
    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<WelcomeViewState, AuthenticationAction>

    public var body: some View {
        VStack {
            WelcomeMessageSection()
                .padding(.top, 140)
            Spacer()
            WelcomeActionSection(store: store, viewStore: viewStore)
                .padding(.bottom, 58)
        }
        .sheet(isPresented: viewStore.binding(
            get: \.isLoginVisible,
            send: AuthenticationAction.setLoginVisible(_:))
        ) {
            LoginView(store: store)
        }
    }

    public init(store: Store<AuthenticationState, AuthenticationAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: WelcomeViewState.init))
    }
}

struct WelcomeViewState: Equatable {
    var isLoginVisible: Bool
    var buildNumber: String
    init(state: AuthenticationState) {
        isLoginVisible = state.isLoginVisible
        buildNumber = state.buildVersion
    }
}

struct WelcomeMessageSection: View {
    var body: some View {
        VStack {
            Image.Logo.blockchain
                .frame(width: 64, height: 64)
                .padding(.bottom, 40)
            Text(WelcomeViewString.title)
                .font(Font(weight: .semibold, size: 24))
                .foregroundColor(.textHeading)
                .padding(.bottom, 16)
            WelcomeMessageDescription()
                .font(Font(weight: .medium, size: 16))
                .lineSpacing(4)
        }
        .multilineTextAlignment(.center)
    }
}

struct WelcomeMessageDescription: View {
    let prefix = Text(WelcomeViewString.Description.prefix)
        .foregroundColor(.textMuted)
    let comma = Text(WelcomeViewString.Description.comma)
        .foregroundColor(.textMuted)
    let receive = Text(WelcomeViewString.Description.receive)
        .foregroundColor(.textHeading)
    let store = Text(WelcomeViewString.Description.store + "\n")
        .foregroundColor(.textHeading)
    let and = Text(WelcomeViewString.Description.and)
        .foregroundColor(.textMuted)
    let trade = Text(WelcomeViewString.Description.trade)
        .foregroundColor(.textHeading)
    let suffix = Text(WelcomeViewString.Description.suffix)
        .foregroundColor(.textMuted)

    var body: some View {
        Group {
            prefix + receive + comma + store + and + trade + suffix
        }
    }
}

struct WelcomeActionSection: View {
    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<WelcomeViewState, AuthenticationAction>

    var body: some View {
        VStack {
            PrimaryButton(title: WelcomeViewString.Button.createAccount) {
                viewStore.send(.createAccount)
            }
            .padding(.bottom, 10)

            SecondaryButton(title: WelcomeViewString.Button.login) {
                viewStore.send(.setLoginVisible(true))
            }
            .padding(.bottom, 20)

            HStack {
                Button(WelcomeViewString.Button.restoreWallet) {
                    viewStore.send(.recoverFunds)
                }
                .font(Font(weight: .semibold, size: 12))
                .foregroundColor(.buttonLinkText)
                Spacer()
                Text(viewStore.buildNumber)
                    .font(Font(weight: .medium, size: 12))
                    .foregroundColor(.textMuted)
            }
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            store:Store(initialState: AuthenticationState(),
                        reducer: authenticationReducer,
                        environment: .init(
                            mainQueue: .main,
                            buildVersionProvider: { "test version" },
                            authenticationService: NoOpAuthenticationService()
                        )
            )
        )
    }
}
#endif
