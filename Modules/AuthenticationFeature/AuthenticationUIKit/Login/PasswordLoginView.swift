// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

public struct PasswordLoginView: View {

    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<PasswordLoginViewState, AuthenticationAction>

    public init(store: Store<AuthenticationState, AuthenticationAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: PasswordLoginViewState.init))
    }

    public var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    FormTextFieldGroup(
                        title: LoginViewString.TextFieldTitle.email,
                        text: viewStore.binding(
                            get: { $0.emailAddress },
                            send: { .didChangeEmailAddress($0) }
                        ),
                        footnote: viewStore.binding(
                            get: {
                                LoginViewString.TextFieldFootnote.wallet +  $0.walletAddress
                            },
                            send: { .didRetrievedWalletAddress($0) }
                        ),
                        isDisabled: true
                    )
                    .padding(EdgeInsets(top: 80, leading: 0, bottom: 20, trailing: 0))
                    FormTextFieldGroup(
                        title: LoginViewString.TextFieldTitle.password,
                        text: viewStore.binding(
                            get: { $0.password },
                            send: { .didChangePassword($0) }
                        ),
                        isSecure: true
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
                    Button(
                        action: {
                            if let url = URL(string: "https://www.google.com") {
                                UIApplication.shared.open(url)
                            }
                        }, label: {
                            Text(LoginViewString.Link.troubleLogInLink)
                                .font(Font(weight: .medium, size: 14))
                        }
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    FormTextFieldGroup(
                        title: LoginViewString.TextFieldTitle.twoFactorAuthCode,
                        text: viewStore.binding(
                            get: { $0.twoFactorAuthCode },
                            send: { .didChangeTwoFactorAuthCode($0) }
                        ),
                        textPlaceholder: "-----"
                    )
                    HStack {
                        Text(LoginViewString.TextFieldFootnote.lostTwoFactorAuthCodePrompt)
                            .textStyle(.subheading)
                        Button(action: {}) {
                            Text(LoginViewString.Link.resetTwoFactorAuthLink)
                                .font(Font(weight: .medium, size: 14))
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    FormTextFieldGroup(
                        title: LoginViewString.TextFieldTitle.hardwareKeyVerify,
                        text: viewStore.binding(
                            get: { $0.hardwareKeyCode },
                            send: { .didChangeHardwareKeyCode($0) }
                        ),
                        isSecure: true
                    )
                    Text(LoginViewString.TextFieldFootnote.hardwareKeyInstruction)
                        .textStyle(.subheading)
                }
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
            }
            PrimaryButton(title: LoginViewString.Button._continue) {
                // TODO: Add continue action here
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 34, trailing: 24))
        }
    }

}

struct PasswordLoginViewState: Equatable {
    var emailAddress: String
    var walletAddress: String
    var password: String
    var twoFactorAuthCode: String
    var hardwareKeyCode: String

    init(state: AuthenticationState) {
        emailAddress = state.emailAddress
        walletAddress = state.walletAddress
        password = state.password
        twoFactorAuthCode = state.twoFactorAuthCode
        hardwareKeyCode = state.hardwareKeyCode
    }
}

struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordLoginView(
            store: Store(initialState: AuthenticationState(),
                         reducer: authenticationReducer,
                         environment: .init(mainQueue: .main)
            )
        )
    }
}
