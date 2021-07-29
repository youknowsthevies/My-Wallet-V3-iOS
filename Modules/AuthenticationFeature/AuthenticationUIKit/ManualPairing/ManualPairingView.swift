// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

private typealias LocalizedTitles = LocalizationConstants.AuthenticationKit.EmailLogin

struct ManualPairingView: View {

    private let store: Store<ManualPairing.State, ManualPairing.Action>
    @ObservedObject private var viewStore: ViewStore<ManualPairing.State, ManualPairing.Action>

    @State private var isWalletIdentifierFieldFirstResponder: Bool = true
    @State private var isPasswordFieldFirstResponder: Bool = false
    @State private var isPasswordVisible: Bool = false

    init(store: Store<ManualPairing.State, ManualPairing.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Group {
                    FormTextFieldGroup(
                        text: viewStore.binding(
                            get: { $0.walletIdentifier },
                            send: { .walletIdentifier($0) }
                        ),
                        isFirstResponder: $isWalletIdentifierFieldFirstResponder,
                        isError: viewStore.binding(
                            get: { $0.incorrectWalletIdentifier },
                            send: .none
                        ),
                        title: LocalizedTitles.TextFieldTitle.walletIdentifier,
                        configuration: {
                            $0.autocorrectionType = .no
                            $0.autocapitalizationType = .none
                            $0.textContentType = .username
                            $0.returnKeyType = .next
                        },
                        errorMessage: LocalizedTitles.TextFieldError.incorrectWalletIdentifier,
                        onPaddingTapped: {
                            self.isWalletIdentifierFieldFirstResponder = true
                            self.isPasswordFieldFirstResponder = false
                        },
                        onReturnTapped: {
                            self.isWalletIdentifierFieldFirstResponder = false
                            self.isPasswordFieldFirstResponder = true
                        }
                    )
                    .padding([.top, .bottom], 20)
                    .accessibility(identifier: AccessibilityIdentifiers.ManualPairingScreen.guidGroup)

                    FormTextFieldGroup(
                        text: viewStore.binding(
                            get: { $0.passwordState.password },
                            send: { .password(.didChangePassword($0)) }
                        ),
                        isFirstResponder: $isPasswordFieldFirstResponder,
                        isError: viewStore.binding(
                            get: { $0.passwordState.isPasswordIncorrect },
                            send: { _ in .none }
                        ),
                        title: LocalizedTitles.TextFieldTitle.password,
                        configuration: {
                            $0.autocorrectionType = .no
                            $0.autocapitalizationType = .none
                            $0.textContentType = .password
                            $0.isSecureTextEntry = !isPasswordVisible
                            $0.returnKeyType = .done
                            $0.enablesReturnKeyAutomatically = true
                        },
                        errorMessage: LocalizedTitles.TextFieldError.incorrectPassword,
                        onPaddingTapped: {
                            self.isWalletIdentifierFieldFirstResponder = false
                            self.isPasswordFieldFirstResponder = true
                        },
                        onReturnTapped: {
                            self.isWalletIdentifierFieldFirstResponder = false
                            self.isPasswordFieldFirstResponder = false
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
                    .padding(.bottom, 10)
                    .accessibility(identifier: AccessibilityIdentifiers.ManualPairingScreen.passwordGroup)

                    Text(warningTitle)
                        .font(.caption)

                    Spacer()

                    VStack(alignment: .center) {
                        PrimaryButton(
                            title: EmailLoginString.Button._continue,
                            action: {
                                viewStore.send(.continue)
                            },
                            loading: viewStore.binding(get: \.isLoggingIn, send: .none)
                        )
                        .padding(.bottom, 34)
                        .disabled(!viewStore.isValid)
                        .accessibility(identifier: AccessibilityIdentifiers.ManualPairingScreen.continueButton)
                    }
                }
                .padding([.leading, .trailing], 24)
            }
            .navigationBarTitle(LocalizedTitles.manualPairingTitle, displayMode: .inline)
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
            .whiteNavigationBarStyle()
            .largeInlineNavigationBarTitle()
            .alert(
                self.store.scope(state: \.alertState),
                dismiss: .alert(.dismiss)
            )
        }
    }
}

private let warningTitle = """
⚠️  This screen is only intended for internal builds,
if you are able to see this on a production build
please report it to any iOS team member.
"""

#if DEBUG
struct ManualPairingView_Previews: PreviewProvider {
    static var previews: some View {
        ManualPairingView(
            store: Store(
                initialState: .init(),
                reducer: manualPairingReducer,
                environment: .init()
            ))
    }
}
#endif
