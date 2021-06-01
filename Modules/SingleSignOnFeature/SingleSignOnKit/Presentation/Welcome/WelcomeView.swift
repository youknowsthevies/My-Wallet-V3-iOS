// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias WelcomeViewString = LocalizationConstants.Onboarding.WelcomeScreen

public struct WelcomeView: View {
    let store: Store<SingleSignOnState, SingleSignOnAction>
    @ObservedObject var viewStore: ViewStore<WelcomeViewState, SingleSignOnAction>

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
            send: SingleSignOnAction.setLoginVisible(_:))
        ) {
            LoginView(store: store)
        }
    }

    public init(store: Store<SingleSignOnState, SingleSignOnAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: WelcomeViewState.init))
    }
}

struct WelcomeViewState: Equatable {
    var isLoginVisible: Bool
    init(state: SingleSignOnState) {
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
    let store: Store<SingleSignOnState, SingleSignOnAction>
    @ObservedObject var viewStore: ViewStore<WelcomeViewState, SingleSignOnAction>

    var body: some View {
        VStack {
            PrimaryButton(title: WelcomeViewString.Button.createWallet) {
                // TODO: add login action here
            }
                .frame(width: 327, height: 48)
                .border(Color.black)
                .cornerRadius(8.0)
                .padding(10)
            SecondaryButton(title: WelcomeViewString.Button.login) {
                viewStore.send(.setLoginVisible(true))
            }
                .frame(width: 327, height: 48)
            HStack {
                Button(WelcomeViewString.Button.recoverFunds) {
                    // TODO: add recover funds action here
                }
                .font(Font(weight: .semibold, size: 12))
                Spacer()
                // TODO: replace test version with actual number later
                Text("Test Version")
                    .font(Font(weight: .medium, size: 12))
            }
            .padding()
            .frame(width: 327, height: 28)
        }
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            store:Store(initialState: SingleSignOnState(),
                        reducer: singleSignOnReducer,
                        environment: .init(mainQueue: DispatchQueue.main.eraseToAnyScheduler())
            )
        )
    }
}
#endif
