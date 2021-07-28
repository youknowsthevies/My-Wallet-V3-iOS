// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

typealias WelcomeViewString = LocalizationConstants.AuthenticationKit.Welcome

/// Entry point to Create Wallet/Login/Restore Wallet
public struct WelcomeView: View {

    private let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject private var viewStore: ViewStore<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        viewStore = ViewStore(store)
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
        .sheet(isPresented: .constant(viewStore.screenFlow == .guidLoginScreen)) {
            IfLetStore(
                store.scope(
                    state: \.manualPairingState,
                    action: WelcomeAction.manualPairing
                ),
                then: ManualPairingView.init(store:)
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
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.blockchainImage)
            Text(WelcomeViewString.title)
                .font(Font(weight: .semibold, size: 24))
                .foregroundColor(.textHeading)
                .padding(.bottom, 16)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeTitleText)
            WelcomeMessageDescription()
                .font(Font(weight: .medium, size: 16))
                .lineSpacing(4)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeMessageText)
        }
        .multilineTextAlignment(.center)
    }
}

private struct WelcomeMessageDescription: View {
    let prefix = Text(WelcomeViewString.Description.prefix)
        .foregroundColor(.textMuted)
    let comma = Text(WelcomeViewString.Description.comma)
        .foregroundColor(.textMuted)
    let send = Text(WelcomeViewString.Description.send)
        .foregroundColor(.textHeading)
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
            prefix + send + comma + receive + comma + store + and + trade + suffix
        }
    }
}

private struct WelcomeActionSection: View {

    let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject var viewStore: ViewStore<WelcomeState, WelcomeAction>

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                PrimaryButton(title: WelcomeViewString.Button.createWallet) {
                    viewStore.send(.presentScreenFlow(.createWalletScreen))
                }
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.createWalletButton)

                SecondaryButton(title: WelcomeViewString.Button.login) {
                    viewStore.send(.presentScreenFlow(.emailLoginScreen))
                }
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.emailLoginButton)

                if viewStore.manualPairingEnabled {
                    Divider()
                    manualPairingButton()
                        .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.manualPairingButton)
                }
            }
            .padding(.bottom, 20)

            HStack {
                Button(WelcomeViewString.Button.restoreWallet) {
                    viewStore.send(.presentScreenFlow(.recoverWalletScreen))
                }
                .font(Font(weight: .semibold, size: 12))
                .foregroundColor(.buttonLinkText)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.restoreWalletButton)
                Spacer()
                Text(viewStore.buildVersion)
                    .font(Font(weight: .medium, size: 12))
                    .foregroundColor(.textMuted)
                    .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.buildVersionText)
            }
        }
        .padding([.leading, .trailing], 24)
    }

    // MARK: - Private

    private func manualPairingButton() -> some View {
        Button(WelcomeViewString.Button.manualPairing) {
            viewStore.send(.presentScreenFlow(.guidLoginScreen))
        }
        .font(Font(weight: .semibold, size: 16))
        .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
        .padding(.horizontal)
        .foregroundColor(Color.textSubheading)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                .fill(Color.buttonSecondaryBackground)
        )
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                .stroke(Color.borderPrimary)
        )
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
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    featureFlags: NoOpInternalFeatureFlagService(),
                    buildVersionProvider: { "Test version" }
                )
            )
        )
    }
}
#endif
