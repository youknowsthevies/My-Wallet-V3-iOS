// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct CredentialsView: View {

    @Binding var isTwoFACodeVisible: Bool
    @Binding var isResendSMSButtonVisible: Bool
    @Binding var isHardwareKeyCodeFieldVisible: Bool
    @Binding var isPasswordIncorrect: Bool
    @Binding var isTwoFACodeIncorrect: Bool
    @Binding var isHardwareKeyCodeVisible: Bool
    @Binding var isAccountLocked: Bool

    private let walletInfo: WalletInfo
    private let store: Store<CredentialsState, CredentialsAction>
    @ObservedObject private var viewStore: ViewStore<CredentialsState, CredentialsAction>

    init(walletInfo: WalletInfo, store: Store<CredentialsState, CredentialsAction>) {
        self.walletInfo = walletInfo
        self.store = store
        let newViewStore = ViewStore(store)
        self.viewStore = newViewStore
        self._isTwoFACodeVisible = newViewStore.binding(
            get: { $0.twoFAState?.isTwoFACodeFieldVisible ?? false },
            send: { _ in .none }
        )
        self._isHardwareKeyCodeFieldVisible = newViewStore.binding(
            get: { $0.hardwareKeyState?.isHardwareKeyCodeFieldVisible ?? false },
            send: { _ in .none }
        )
        self._isPasswordIncorrect = newViewStore.binding(
            get: { $0.passwordState?.isPasswordIncorrect ?? false },
            send: { _ in .none }
        )
        self._isTwoFACodeIncorrect = newViewStore.binding(
            get: { $0.twoFAState?.isTwoFACodeIncorrect ?? false },
            send: { _ in .none }
        )
        self._isHardwareKeyCodeVisible = newViewStore.binding(
            get: { $0.hardwareKeyState?.isHardwareKeyCodeIncorrect ?? false },
            send: { _ in .none }
        )
        self._isAccountLocked = newViewStore.binding(
            get: { $0.isAccountLocked },
            send: { _ in .none }
        )
        self._isResendSMSButtonVisible = newViewStore.binding(
            get: { $0.twoFAState?.isResendSMSButtonVisible ?? false },
            send: { _ in .none }
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            FormTextFieldGroup(
                title: EmailLoginString.TextFieldTitle.email,
                text: .constant(walletInfo.email),
                footnote: EmailLoginString.TextFieldFootnote.wallet + walletInfo.guid,
                isDisabled: true
            )
            .padding(.top, 20)
            .padding(.bottom, 20)

            FormTextFieldGroup(
                title: EmailLoginString.TextFieldTitle.password,
                text: viewStore.binding(
                    get: { $0.passwordState?.password ?? "" },
                    send: { .password(.didChangePassword($0)) }
                ),
                isSecure: true,
                error: { _ in isPasswordIncorrect || isAccountLocked },
                errorMessage: isAccountLocked ?
                    EmailLoginString.TextFieldError.accountLocked :
                    EmailLoginString.TextFieldError.incorrectPassword
            )
            .padding(.bottom, 1)

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
                        )
                )

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
            }

            if isHardwareKeyCodeFieldVisible {
                FormTextFieldGroup(
                    title: EmailLoginString.TextFieldTitle.hardwareKeyCode,
                    text: viewStore.binding(
                        get: { $0.hardwareKeyState?.hardwareKeyCode ?? "" },
                        send: { .hardwareKey(.didChangeHardwareKeyCode($0)) }
                    ),
                    isSecure: true,
                    error: { _ in isHardwareKeyCodeFieldVisible },
                    errorMessage: EmailLoginString.TextFieldError.incorrectHardwareKeyCode
                )
                Text(EmailLoginString.TextFieldFootnote.hardwareKeyInstruction)
                    .textStyle(.subheading)
            }

            Spacer()

            PrimaryButton(title: EmailLoginString.Button._continue) {
                if viewStore.isTwoFACodeOrHardwareKeyVerified {
                    viewStore.send(.walletPairing(.decryptWalletWithPassword(viewStore.passwordState?.password ?? "")))
                } else {
                    viewStore.send(.walletPairing(.authenticate))
                }
            }
            .padding(.bottom, 58)
        }
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .onAppear {
            viewStore.send(
                .didAppear(
                    emailAddress: walletInfo.email,
                    walletGuid: walletInfo.guid,
                    emailCode: walletInfo.emailCode
                )
            )
        }
        .onDisappear {
            viewStore.send(.didDisappear)
        }
        .alert(self.store.scope(state: \.credentialsFailureAlert), dismiss: .credentialsFailureAlert(.dismiss))
    }
}

#if DEBUG
struct PasswordLoginView_Previews: PreviewProvider {
    static var previews: some View {
        CredentialsView(
            walletInfo: WalletInfo.empty,
            store: Store(
                initialState: .init(),
                reducer: credentialsReducer,
                environment: .init()
            )
        )
    }
}
#endif
