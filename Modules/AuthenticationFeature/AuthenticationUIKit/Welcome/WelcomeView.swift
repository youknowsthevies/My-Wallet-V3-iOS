// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias WelcomeViewString = LocalizationConstants.AuthenticationKit.Welcome

public struct WelcomeView: View {

    private let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject private var viewStore: ViewStore<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            WelcomeMessageSection()
                .padding(.top, 140)
            Spacer()
            WelcomeActionSection(store: store, viewStore: viewStore)
                .padding(.bottom, 58)
        }
        .sheet(isPresented: .constant(viewStore.screenFlow == .emailLoginScreen)) {
            IfLetStore(
                store.scope(
                    state: \.emailLoginState,
                    action: WelcomeAction.emailLogin
                ),
                then: EmailLoginView.init(store:)
            )
        }
    }
}

private struct WelcomeMessageSection: View {
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

private struct WelcomeMessageDescription: View {
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

private struct WelcomeActionSection: View {

    let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject var viewStore: ViewStore<WelcomeState, WelcomeAction>

    var body: some View {
        VStack {
            PrimaryButton(title: WelcomeViewString.Button.createWallet) {
                viewStore.send(.presentScreenFlow(.createWalletScreen))
            }
            .padding(.bottom, 10)

            SecondaryButton(title: WelcomeViewString.Button.login) {
                viewStore.send(.presentScreenFlow(.emailLoginScreen))
            }
            .padding(.bottom, 20)

            HStack {
                Button(WelcomeViewString.Button.restoreWallet) {
                    viewStore.send(.presentScreenFlow(.recoverWalletScreen))
                }
                .font(Font(weight: .semibold, size: 12))
                .foregroundColor(.buttonLinkText)
                Spacer()
                Text(viewStore.buildVersion)
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
            store: Store(
                initialState: .init(),
                reducer: welcomeReducer,
                environment: .init(
                    mainQueue: .main,
                    buildVersionProvider: { "Test version" }
                )
            )
        )
    }
}
#endif
