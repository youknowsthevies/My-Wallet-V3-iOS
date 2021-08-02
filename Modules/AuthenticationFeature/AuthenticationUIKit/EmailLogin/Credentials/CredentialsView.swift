// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct CredentialsView: View {

    private let context: CredentialsContext
    private let store: Store<CredentialsState, CredentialsAction>
    @ObservedObject private var viewStore: ViewStore<CredentialsState, CredentialsAction>

    private var twoFAErrorMessage: String {
        guard !viewStore.isAccountLocked else {
            return EmailLoginString.TextFieldError.accountLocked
        }
        guard let twoFAState = viewStore.twoFAState,
              twoFAState.isTwoFACodeIncorrect
        else {
            return ""
        }
        switch twoFAState.twoFACodeIncorrectContext {
        case .incorrect:
            return String(
                format: EmailLoginString.TextFieldError.incorrectTwoFACode,
                viewStore.twoFAState?.twoFACodeAttemptsLeft ?? 0
            )
        case .missingCode:
            return EmailLoginString.TextFieldError.missingTwoFACode
        case .none:
            return ""
        }
    }

    @State private var isWalletIdentifierFirstResponder: Bool = false
    @State private var isPasswordFieldFirstResponder: Bool = false
    @State private var isTwoFAFieldFirstResponder: Bool = false
    @State private var isHardwareKeyCodeFieldFirstResponder: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isHardwareKeyCodeVisible: Bool = false

    init(context: CredentialsContext, store: Store<CredentialsState, CredentialsAction>) {
        self.context = context
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            emailOrWalletIdentifierView()
            FormTextFieldGroup(
                text: viewStore.binding(
                    get: \.passwordState.password,
                    send: { .password(.didChangePassword($0)) }
                ),
                isFirstResponder: $isPasswordFieldFirstResponder,
                isError: viewStore.binding(
                    get: { $0.passwordState.isPasswordIncorrect || $0.isAccountLocked },
                    send: .none
                ),
                title: EmailLoginString.TextFieldTitle.password,
                configuration: {
                    $0.autocorrectionType = .no
                    $0.autocapitalizationType = .none
                    $0.isSecureTextEntry = !isPasswordVisible
                    $0.textContentType = .password
                },
                errorMessage: viewStore.isAccountLocked ?
                    EmailLoginString.TextFieldError.accountLocked :
                    EmailLoginString.TextFieldError.incorrectPassword,
                onPaddingTapped: {
                    self.isWalletIdentifierFirstResponder = false
                    self.isPasswordFieldFirstResponder = true
                    self.isTwoFAFieldFirstResponder = false
                    self.isHardwareKeyCodeFieldFirstResponder = false
                },
                onReturnTapped: {
                    self.isWalletIdentifierFirstResponder = false
                    self.isPasswordFieldFirstResponder = false
                    self.isTwoFAFieldFirstResponder = true
                    self.isHardwareKeyCodeFieldFirstResponder = true
                },
                trailingAccessoryView: {
                    Button(
                        action: { isPasswordVisible.toggle() },
                        label: {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(Color.secureFieldEyeSymbol)
                        }
                    )
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

            if let state = viewStore.twoFAState, state.isTwoFACodeFieldVisible {
                FormTextFieldGroup(
                    text: viewStore.binding(
                        get: { $0.twoFAState?.twoFACode ?? "" },
                        send: { .twoFA(.didChangeTwoFACode($0)) }
                    ),
                    isFirstResponder: $isTwoFAFieldFirstResponder,
                    isError: viewStore.binding(
                        get: { $0.twoFAState?.isTwoFACodeIncorrect ?? false || $0.isAccountLocked },
                        send: .none
                    ),
                    title: EmailLoginString.TextFieldTitle.twoFACode,
                    configuration: {
                        $0.autocorrectionType = .no
                        $0.autocapitalizationType = .none
                        $0.textContentType = .oneTimeCode
                        $0.returnKeyType = .done
                    },
                    errorMessage: twoFAErrorMessage,
                    onPaddingTapped: {
                        self.isWalletIdentifierFirstResponder = false
                        self.isPasswordFieldFirstResponder = false
                        self.isTwoFAFieldFirstResponder = true
                        self.isHardwareKeyCodeFieldFirstResponder = false
                    },
                    onReturnTapped: {
                        self.isWalletIdentifierFirstResponder = false
                        self.isPasswordFieldFirstResponder = false
                        self.isTwoFAFieldFirstResponder = false
                        self.isHardwareKeyCodeFieldFirstResponder = false
                    }
                )
                .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.twoFAGroup)

                if let state = viewStore.twoFAState, state.isResendSMSButtonVisible {
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

            if let state = viewStore.hardwareKeyState, state.isHardwareKeyCodeFieldVisible {
                FormTextFieldGroup(
                    text: viewStore.binding(
                        get: { $0.hardwareKeyState?.hardwareKeyCode ?? "" },
                        send: { .hardwareKey(.didChangeHardwareKeyCode($0)) }
                    ),
                    isFirstResponder: $isHardwareKeyCodeFieldFirstResponder,
                    isError: viewStore.binding(
                        get: { $0.hardwareKeyState?.isHardwareKeyCodeIncorrect ?? false || $0.isAccountLocked },
                        send: .none
                    ),
                    title: EmailLoginString.TextFieldTitle.hardwareKeyCode,
                    configuration: {
                        $0.autocorrectionType = .no
                        $0.autocapitalizationType = .none
                        $0.isSecureTextEntry = !isHardwareKeyCodeVisible
                        $0.textContentType = .password
                    },
                    errorMessage: viewStore.isAccountLocked ?
                        EmailLoginString.TextFieldError.accountLocked :
                        EmailLoginString.TextFieldError.incorrectHardwareKeyCode,
                    onPaddingTapped: {
                        self.isWalletIdentifierFirstResponder = false
                        self.isPasswordFieldFirstResponder = false
                        self.isTwoFAFieldFirstResponder = false
                        self.isHardwareKeyCodeFieldFirstResponder = true
                    },
                    onReturnTapped: {
                        self.isWalletIdentifierFirstResponder = false
                        self.isPasswordFieldFirstResponder = false
                        self.isTwoFAFieldFirstResponder = false
                        self.isHardwareKeyCodeFieldFirstResponder = false
                    },
                    trailingAccessoryView: {
                        Button(
                            action: { isHardwareKeyCodeVisible.toggle() },
                            label: {
                                Image(systemName: isHardwareKeyCodeVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Color.secureFieldEyeSymbol)
                            }
                        )
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
        .navigationBarTitle(EmailLoginString.navigationTitle, displayMode: .inline)
        .onAppear {
            viewStore.send(.didAppear(context: context))
        }
        .onDisappear {
            viewStore.send(.didDisappear)
        }
        .alert(self.store.scope(state: \.credentialsFailureAlert), dismiss: .alert(.dismiss))
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
            text: .constant(viewStore.emailAddress),
            isFirstResponder: .constant(false),
            isError: .constant(false),
            title: EmailLoginString.TextFieldTitle.email,
            footnote: EmailLoginString.TextFieldFootnote.wallet + viewStore.walletGuid,
            isPrefilledAndDisabled: true
        )
        .padding([.top, .bottom], 20)
        .accessibility(identifier: AccessibilityIdentifiers.CredentialsScreen.emailGuidGroup)
    }

    private func walletIdentifierTextfield() -> some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: { $0.walletGuid },
                send: { .didChangeWalletIdentifier($0) }
            ),
            isFirstResponder: $isWalletIdentifierFirstResponder,
            isError: viewStore.binding(
                get: \.isWalletIdentifierIncorrect,
                send: .none
            ),
            title: EmailLoginString.TextFieldTitle.walletIdentifier,
            footnote: EmailLoginString.TextFieldFootnote.email + viewStore.emailAddress,
            configuration: {
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.textContentType = .username
                $0.returnKeyType = .next
            },
            onPaddingTapped: {
                self.isWalletIdentifierFirstResponder = true
                self.isPasswordFieldFirstResponder = false
                self.isTwoFAFieldFirstResponder = false
                self.isHardwareKeyCodeFieldFirstResponder = false
            },
            onReturnTapped: {
                self.isWalletIdentifierFirstResponder = false
                self.isPasswordFieldFirstResponder = true
                self.isTwoFAFieldFirstResponder = false
                self.isHardwareKeyCodeVisible = false
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
