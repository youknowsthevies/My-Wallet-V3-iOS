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

    @Binding var isWalletIdentifierIncorrect: Bool
    @Binding var isPasswordIncorrect: Bool

    init(store: Store<ManualPairing.State, ManualPairing.Action>) {
        self.store = store
        let viewStore = ViewStore(store)
        self.viewStore = viewStore
        _isPasswordIncorrect = viewStore.binding(
            get: { $0.passwordState.isPasswordIncorrect },
            send: { _ in .none }
        )
        _isWalletIdentifierIncorrect = viewStore.binding(
            get: \.incorrectWalletIdentifier,
            send: .none
        )
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Group {
                    FormTextFieldGroup(
                        title: LocalizedTitles.TextFieldTitle.walletIdentifier,
                        text: viewStore.binding(
                            get: { $0.walletIdentifier },
                            send: { value in .walletIdentifier(value) }
                        ),
                        isDisabled: false,
                        error: { _ in isWalletIdentifierIncorrect },
                        errorMessage: LocalizedTitles.TextFieldError.incorrectWalletIdentifier
                    )
                    .padding([.top, .bottom], 20)
                    .accessibility(identifier: AccessibilityIdentifiers.ManualPairingScreen.guidGroup)

                    FormTextFieldGroup(
                        title: LocalizedTitles.TextFieldTitle.password,
                        text: viewStore.binding(
                            get: { $0.passwordState.password },
                            send: { .password(.didChangePassword($0)) }
                        ),
                        isSecure: true,
                        error: { _ in isPasswordIncorrect },
                        errorMessage: LocalizedTitles.TextFieldError.incorrectPassword
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
                        .padding(.bottom, 58)
                        .disabled(!viewStore.isValid)
                        .accessibility(identifier: AccessibilityIdentifiers.ManualPairingScreen.continueButton)
                    }
                }
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(.leading, 24)
                .padding(.trailing, 24)
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
