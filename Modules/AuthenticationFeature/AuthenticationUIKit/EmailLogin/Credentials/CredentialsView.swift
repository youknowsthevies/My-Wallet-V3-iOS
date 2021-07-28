// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct CredentialsView: View {

    @Binding var isTwoFACodeVisible: Bool
    @Binding var isResendSMSButtonVisible: Bool
    @Binding var isHardwareKeyCodeFieldVisible: Bool
    @Binding var isHardwareKeyCodeFieldFocused: Bool
    @Binding var isWalletIdentifierIncorrect: Bool
    @Binding var isPasswordIncorrect: Bool
    @Binding var isPasswordFieldFocused: Bool
    @Binding var isTwoFACodeIncorrect: Bool
    @Binding var isHardwareKeyCodeIncorrect: Bool
    @Binding var isAccountLocked: Bool

    private let context: CredentialsContext
    private let store: Store<CredentialsState, CredentialsAction>
    @ObservedObject private var viewStore: ViewStore<CredentialsState, CredentialsAction>

    init(context: CredentialsContext, store: Store<CredentialsState, CredentialsAction>) {
        self.context = context
        self.store = store
        let viewStore = ViewStore(store)
        self.viewStore = viewStore
        _isTwoFACodeVisible = viewStore.binding(
            get: { $0.twoFAState?.isTwoFACodeFieldVisible ?? false },
            send: { _ in .none }
        )
        _isHardwareKeyCodeFieldVisible = viewStore.binding(
            get: { $0.hardwareKeyState?.isHardwareKeyCodeFieldVisible ?? false },
            send: { _ in .none }
        )
        _isPasswordIncorrect = viewStore.binding(
            get: \.passwordState.isPasswordIncorrect,
            send: { _ in .none }
        )
        _isWalletIdentifierIncorrect = viewStore.binding(
            get: \.isWalletIdentifierIncorrect,
            send: .none
        )
        _isTwoFACodeIncorrect = viewStore.binding(
            get: { $0.twoFAState?.isTwoFACodeIncorrect ?? false },
            send: { _ in .none }
        )
        _isHardwareKeyCodeIncorrect = viewStore.binding(
            get: { $0.hardwareKeyState?.isHardwareKeyCodeIncorrect ?? false },
            send: { _ in .none }
        )
        _isAccountLocked = viewStore.binding(
            get: { $0.isAccountLocked },
            send: { _ in .none }
        )
        _isResendSMSButtonVisible = viewStore.binding(
            get: { $0.twoFAState?.isResendSMSButtonVisible ?? false },
            send: { _ in .none }
        )
        _isPasswordFieldFocused = viewStore.binding(
            get: \.passwordState.isFocused,
            send: { _ in .none }
        )
        _isHardwareKeyCodeFieldFocused = viewStore.binding(
            get: { $0.hardwareKeyState?.isFocused ?? false },
            send: { _ in .none }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            emailOrWalletIdentifierView()
            FormTextFieldGroup(
                title: EmailLoginString.TextFieldTitle.password,
                text: viewStore.binding(
                    get: \.passwordState.password,
                    send: { .password(.didChangePassword($0)) }
                ),
                isSecure: true,
                isSecureFieldFocused: $isPasswordFieldFocused,
                error: { _ in isPasswordIncorrect || isAccountLocked },
                errorMessage: isAccountLocked ?
                    EmailLoginString.TextFieldError.accountLocked :
                    EmailLoginString.TextFieldError.incorrectPassword,
                resetFocus: {
                    viewStore.send(.password(.didChangeFocusedState(true)))
                    viewStore.send(.hardwareKey(.didChangeFocusedState(false)))
                }
            )
            .padding(.bottom, 1)
            .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.passwordGroup)

            Button(
                action: {
                    // TODO: Link to Account recovery
                },
                label: {
                    Text(EmailLoginString.Link.troubleLogInLink)
                        .font(Font(weight: .medium, size: 14))
                        .foregroundColor(.buttonLinkText)
                }
            )
            .padding(.bottom, 16)
            .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.troubleLoggingInButton)

            if isTwoFACodeVisible {
                FormTextFieldGroup(
                    title: EmailLoginString.TextFieldTitle.twoFACode,
                    text: viewStore.binding(
                        get: { $0.twoFAState?.twoFACode ?? "" },
                        send: { .twoFA(.didChangeTwoFACode($0)) }
                    ),
                    error: { _ in isTwoFACodeIncorrect || isAccountLocked },
                    errorMessage:
                    isAccountLocked ?
                        EmailLoginString.TextFieldError.accountLocked :
                        String(
                            format: EmailLoginString.TextFieldError.incorrectTwoFACode,
                            viewStore.twoFAState?.twoFACodeAttemptsLeft ?? 0
                        ),
                    resetFocus: {
                        viewStore.send(.password(.didChangeFocusedState(false)))
                        viewStore.send(.hardwareKey(.didChangeFocusedState(false)))
                    }
                )
                .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.twoFAGroup)

                if isResendSMSButtonVisible {
                    Button(
                        action: {
                            viewStore.send(.walletPairing(.requestSMSCode))
                        },
                        label: {
                            Text(EmailLoginString.Button.resendSMS)
                                .font(Font(weight: .medium, size: 14))
                                .foregroundColor(.buttonLinkText)
                        }
                    )
                    .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.resendSMSButton)
                }

                HStack {
                    Text(EmailLoginString.TextFieldFootnote.lostTwoFACodePrompt)
                        .textStyle(.subheading)
                    Button(
                        action: {
                            guard let url = URL(string: Constants.Url.resetTwoFA) else { return }
                            UIApplication.shared.open(url)
                        },
                        label: {
                            Text(EmailLoginString.Link.resetTwoFALink)
                                .font(Font(weight: .medium, size: 14))
                                .foregroundColor(.buttonLinkText)
                        }
                    )
                }
                .padding(.bottom, 16)
                .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.resetTwoFAButton)
            }

            if isHardwareKeyCodeFieldVisible {
                FormTextFieldGroup(
                    title: EmailLoginString.TextFieldTitle.hardwareKeyCode,
                    text: viewStore.binding(
                        get: { $0.hardwareKeyState?.hardwareKeyCode ?? "" },
                        send: { .hardwareKey(.didChangeHardwareKeyCode($0)) }
                    ),
                    isSecure: true,
                    isSecureFieldFocused: $isHardwareKeyCodeFieldFocused,
                    error: { _ in isHardwareKeyCodeFieldVisible },
                    errorMessage: EmailLoginString.TextFieldError.incorrectHardwareKeyCode,
                    resetFocus: {
                        viewStore.send(.password(.didChangeFocusedState(false)))
                        viewStore.send(.hardwareKey(.didChangeFocusedState(true)))
                    }
                )
                .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.hardwareKeyGroup)
                Text(EmailLoginString.TextFieldFootnote.hardwareKeyInstruction)
                    .textStyle(.subheading)
            }

            Spacer()

            PrimaryButton(
                title: EmailLoginString.Button._continue,
                action: {
                    if viewStore.isTwoFACodeOrHardwareKeyVerified {
                        viewStore.send(.walletPairing(.decryptWalletWithPassword(viewStore.passwordState.password)))
                    } else {
                        viewStore.send(.walletPairing(.authenticate))
                    }
                },
                loading: viewStore.binding(get: \.isLoading, send: .none)
            )
            .padding(.bottom, 34)
        }
        .padding([.leading, .trailing], 24)
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .navigationBarTitle(EmailLoginString.navigationTitle, displayMode: .inline)
        .onAppear {
            viewStore.send(.didAppear(context: context))
        }
        .onDisappear {
            viewStore.send(.didDisappear)
        }
        .alert(self.store.scope(state: \.credentialsFailureAlert), dismiss: .credentialsFailureAlert(.dismiss))
    }

    // MARK: - Private

    private func emailOrWalletIdentifierView() -> AnyView {
        switch context {
        case .walletInfo(let info):
            return AnyView(emailTextfield(info: info))
        case .walletIdentifier:
            return AnyView(walletIdentifierTextfield())
        case .none:
            return AnyView(Divider().foregroundColor(.clear))
        }
    }

    private func emailTextfield(info: WalletInfo) -> some View {
        FormTextFieldGroup(
            title: EmailLoginString.TextFieldTitle.email,
            text: .constant(viewStore.emailAddress),
            footnote: EmailLoginString.TextFieldFootnote.wallet + viewStore.walletGuid,
            isDisabled: true,
            resetFocus: {
                viewStore.send(.password(.didChangeFocusedState(false)))
                viewStore.send(.hardwareKey(.didChangeFocusedState(false)))
            }
        )
        .padding([.top, .bottom], 20)
        .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.emailGuidGroup)
    }

    private func walletIdentifierTextfield() -> some View {
        FormTextFieldGroup(
            title: EmailLoginString.TextFieldTitle.walletIdentifier,
            text: viewStore.binding(
                get: { $0.walletGuid },
                send: { .didChangeWalletIdentifier($0) }
            ),
            footnote: EmailLoginString.TextFieldFootnote.email + viewStore.emailAddress,
            isDisabled: false,
            error: { _ in isWalletIdentifierIncorrect },
            errorMessage: "",
            resetFocus: {
                viewStore.send(.password(.didChangeFocusedState(false)))
                viewStore.send(.hardwareKey(.didChangeFocusedState(false)))
            }
        )
        .padding([.top, .bottom], 20)
        .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.guidGroup)
    }
}

#if DEBUG
struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(
            context: .none,
            store: Store(
                initialState: .init(),
                reducer: credentialsReducer,
                environment: .init(
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecorder()
                )
            )
        )
    }
}
#endif
