// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

public struct CredentialsView: View {
    let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject var viewStore: ViewStore<CredentialsViewState, WelcomeAction>
    @Binding var isTwoFACodeFieldVisible: Bool
    @Binding var isResendSMSButtonVisible: Bool
    @Binding var isHardwareKeyCodeFieldVisible: Bool
    @Binding var isPasswordIncorrect: Bool
    @Binding var isTwoFACodeIncorrect: Bool
    @Binding var isHardwareKeyCodeIncorrect: Bool
    @Binding var isAccountLocked: Bool

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        let newViewStore = ViewStore(self.store.scope(state: CredentialsViewState.init))
        self.viewStore = newViewStore
        self._isTwoFACodeFieldVisible = newViewStore.binding(
            get: { $0.isTwoFACodeVisible },
            send: { _ in .none }
        )
        self._isHardwareKeyCodeFieldVisible = newViewStore.binding(
            get: { $0.isHardwareKeyCodeFieldVisible },
            send: { _ in .none }
        )
        self._isPasswordIncorrect = newViewStore.binding(
            get: { $0.isPasswordIncorrect },
            send: { _ in .none }
        )
        self._isTwoFACodeIncorrect = newViewStore.binding(
            get: { $0.isTwoFACodeIncorrect },
            send: { _ in .none }
        )
        self._isHardwareKeyCodeIncorrect = newViewStore.binding(
            get: { $0.isHardwareKeyCodeIncorrect },
            send: { _ in .none }
        )
        self._isAccountLocked = newViewStore.binding(
            get: { $0.isAccountLocked },
            send: { _ in .none }
        )
        self._isResendSMSButtonVisible = newViewStore.binding(
            get: { $0.isResendSMSButtonVisible },
            send: { _ in .none }
        )
    }

    public var body: some View {
        VStack(alignment: .leading) {
            FormTextFieldGroup(
                title: LoginViewString.TextFieldTitle.email,
                text: viewStore.binding(
                    get: { $0.emailAddress },
                    send: { .didChangeEmailAddress($0) }
                ),
                footnote: LoginViewString.TextFieldFootnote.wallet + viewStore.walletAddress,
                isDisabled: true
            )
            .padding(.top, 20)
            .padding(.bottom, 20)

            FormTextFieldGroup(
                title: LoginViewString.TextFieldTitle.password,
                text: viewStore.binding(
                    get: { $0.password },
                    send: { .didChangePassword($0) }
                ),
                isSecure: true,
                error: { _ in isPasswordIncorrect || isAccountLocked },
                errorMessage: isAccountLocked ? LoginViewString.TextFieldFootnote.accountLocked : LoginViewString.TextFieldFootnote.incorrectPassword
            )
            .padding(.bottom, 1)

            Button(
                action: {
                    // TODO: Link to Account recovery
                },
                label: {
                    Text(LoginViewString.Link.troubleLogInLink)
                        .font(Font(weight: .medium, size: 14))
                        .foregroundColor(.buttonLinkText)
                }
            )
            .padding(.bottom, 16)

            if isTwoFACodeFieldVisible {
                FormTextFieldGroup(
                    title: LoginViewString.TextFieldTitle.twoFACode,
                    text: viewStore.binding(
                        get: { $0.twoFACode },
                        send: { .didChangeTwoFACode($0) }
                    ),
                    error: { _ in isTwoFACodeIncorrect || isAccountLocked },
                    errorMessage:
                        isAccountLocked ?
                        LoginViewString.TextFieldFootnote.accountLocked :
                        String(format: LoginViewString.TextFieldFootnote.incorrectTwoFACode, viewStore.twoFACodeAttemptsLeft)
                )

                if isResendSMSButtonVisible {
                    Button(
                        action: {
                            viewStore.send(.requestOTPMessage)
                        },
                        label: {
                            Text(LoginViewString.Button.resendSMS)
                                .font(Font(weight: .medium, size: 14))
                                .foregroundColor(.buttonLinkText)
                        }
                    )
                }

                HStack {
                    Text(LoginViewString.TextFieldFootnote.lostTwoFACodePrompt)
                        .textStyle(.subheading)
                    Button(
                        action: {
                            guard let url = URL(string: Constants.Url.resetTwoFA) else { return }
                            UIApplication.shared.open(url)
                        },
                        label: {
                            Text(LoginViewString.Link.resetTwoFALink)
                                .font(Font(weight: .medium, size: 14))
                                .foregroundColor(.buttonLinkText)
                        }
                    )
                }
                .padding(.bottom, 16)
            }

            if isHardwareKeyCodeFieldVisible {
                FormTextFieldGroup(
                    title: LoginViewString.TextFieldTitle.hardwareKeyCode,
                    text: viewStore.binding(
                        get: { $0.hardwareKeyCode },
                        send: { .didChangeHardwareKeyCode($0) }
                    ),
                    isSecure: true,
                    error: { _ in isHardwareKeyCodeIncorrect },
                    errorMessage: LoginViewString.TextFieldFootnote.incorrectHardwareKeyCode
                )
                Text(LoginViewString.TextFieldFootnote.hardwareKeyInstruction)
                    .textStyle(.subheading)
            }

            Spacer()

            PrimaryButton(title: LoginViewString.Button._continue) {
                if viewStore.isTwoFACodeVerified {
                    viewStore.send(.authenticateWithPassword(viewStore.password))
                } else {
                    viewStore.send(.authenticate)
                }
            }
            .padding(.bottom, 58)
        }
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .onDisappear {
            viewStore.send(.cancelPollingTimer)
        }
        .alert(self.store.scope(state: \.alert), dismiss: .alert(.dismiss))
    }
}

struct CredentialsViewState: Equatable {
    var emailAddress: String
    var walletAddress: String
    var password: String
    var twoFACode: String
    var hardwareKeyCode: String
    var isTwoFACodeVisible: Bool
    var isResendSMSButtonVisible: Bool
    var isHardwareKeyCodeFieldVisible: Bool
    var isPasswordIncorrect: Bool
    var isTwoFACodeIncorrect: Bool
    var twoFACodeAttemptsLeft: Int
    var isHardwareKeyCodeIncorrect: Bool
    var isAccountLocked: Bool
    var isTwoFACodeVerified: Bool

    init(state: WelcomeState) {
        emailAddress = state.emailAddress
        walletAddress = state.walletInfo?.guid ?? ""
        password = state.password
        twoFACode = state.twoFACode
        hardwareKeyCode = state.hardwareKeyCode
        isTwoFACodeVisible = state.isTwoFACodeFieldVisible
        isResendSMSButtonVisible = state.isResendSMSButtonVisible
        isHardwareKeyCodeFieldVisible = state.isHardwareKeyCodeFieldVisible
        isPasswordIncorrect = state.isPasswordIncorrect
        isTwoFACodeIncorrect = state.isTwoFACodeIncorrect
        twoFACodeAttemptsLeft = state.twoFACodeAttemptsLeft
        isHardwareKeyCodeIncorrect = state.isHardwareKeyCodeIncorrect
        isAccountLocked = state.isAccountLocked
        isTwoFACodeVerified = state.isTwoFACodeVerified
    }
}

#if DEBUG
struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(
            store: Store(
                initialState: WelcomeState(),
                reducer: welcomeReducer,
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
