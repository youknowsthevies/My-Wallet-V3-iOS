// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

public struct CredentialsView: View {
    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<CredentialsViewState, AuthenticationAction>

    public init(store: Store<AuthenticationState, AuthenticationAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: CredentialsViewState.init))
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
                                LoginViewString.TextFieldFootnote.wallet + $0.walletAddress
                            },
                            send: { .didRetrievedWalletAddress($0) }
                        ),
                        isDisabled: true
                    )
                    .padding(.bottom, 20)

                    FormTextFieldGroup(
                        title: LoginViewString.TextFieldTitle.password,
                        text: viewStore.binding(
                            get: { $0.password },
                            send: { .didChangePassword($0) }
                        ),
                        isSecure: true
                    )
                    .padding(.bottom, 1)

                    Button(
                        action: {
                            // Add link action here
                        },
                        label: {
                            Text(LoginViewString.Link.troubleLogInLink)
                                .font(Font(weight: .medium, size: 14))
                                .foregroundColor(.buttonLinkText)
                        }
                    )
                    .padding(.bottom, 16)

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
                        Button(
                            action: {
                                // Add reset 2FA action here
                            },
                            label: {
                                Text(LoginViewString.Link.resetTwoFactorAuthLink)
                                    .font(Font(weight: .medium, size: 14))
                                    .foregroundColor(.buttonLinkText)
                            }
                        )
                    }
                    .padding(.bottom, 16)

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
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(EdgeInsets(top: 80, leading: 24, bottom: 0, trailing: 24))
            }

            PrimaryButton(title: LoginViewString.Button._continue) {
                // Add Authentication actoin here
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 58, trailing: 24))
        }
    }

}

struct CredentialsViewState: Equatable {
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
        CredentialsView(
            store: Store(initialState: AuthenticationState(),
                         reducer: authenticationReducer,
                         environment: .init(mainQueue: .main)
            )
        )
    }
}
