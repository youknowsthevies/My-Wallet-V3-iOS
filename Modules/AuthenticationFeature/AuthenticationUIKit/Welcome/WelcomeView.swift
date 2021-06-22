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
                .padding(EdgeInsets(top: 173, leading: 0, bottom: 0, trailing: 0))
            Spacer()
            WelcomeActionSection(store: store, viewStore: viewStore)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 58, trailing: 0))
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
    init(state: AuthenticationState) {
        isLoginVisible = state.isLoginVisible
    }
}

struct WelcomeMessageSection: View {
    var body: some View {
        VStack {
            Image.Logo.blockchain
                .frame(width: 64, height: 64)
                .padding(40)
            Text(WelcomeViewString.title)
                .font(Font(weight: .semibold, size: 24))
                .foregroundColor(.textHeading)
                .padding(16)
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
                // add login action here
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .cornerRadius(8.0)
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 10, trailing: 24))

            SecondaryButton(title: WelcomeViewString.Button.login) {
                viewStore.send(.setLoginVisible(true))
            }
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 10, trailing: 24))

            HStack {
                Button(WelcomeViewString.Button.recoverFunds) {
                    // add recover funds action here
                }
                .font(Font(weight: .semibold, size: 12))
                Spacer()
                // replace test version with actual number later
                Text("Test Version")
                    .font(Font(weight: .medium, size: 12))
            }
            .frame(height: 28)
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            store:Store(initialState: AuthenticationState(),
                        reducer: authenticationReducer,
                        environment: .init(
                            mainQueue: .main
                        )
            )
        )
    }
}
#endif
