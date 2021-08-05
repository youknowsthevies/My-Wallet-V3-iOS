// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct ResetPasswordView: View {

    private typealias LocalizedString = LocalizationConstants.AuthenticationKit.ResetPassword

    private enum Layout {
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 34
        static let messageBottomPadding: CGFloat = 20
        static let textFieldBottomPadding: CGFloat = 16
    }

    private let store: Store<ResetPasswordState, ResetPasswordAction>
    @ObservedObject private var viewStore: ViewStore<ResetPasswordState, ResetPasswordAction>

    @State private var isNewPasswordFieldFirstResponder: Bool = true
    @State private var isConfirmNewPasswordFieldFirstResponder: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmNewPasswordVisible: Bool = false

    init(store: Store<ResetPasswordState, ResetPasswordAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedString.message)
                .textStyle(.body)
                .multilineTextAlignment(.leading)
                .padding(.bottom, Layout.messageBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.messageText)

            newPasswordField
                .padding(.bottom, Layout.textFieldBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.newPasswordGroup)

            confirmNewPasswordField
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.confirmNewPasswordGroup)

            Spacer()

            PrimaryButton(title: LocalizedString.Button.resetPassword) {
                // TODO: reset password operation
            }
            .disabled(viewStore.newPassword.isEmpty || viewStore.newPassword != viewStore.confirmNewPassword)
            .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.resetPasswordButton)
        }
        .navigationBarTitle(LocalizedString.navigationTitle, displayMode: .inline)
        .hideBackButtonTitle()
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .onDisappear {
            viewStore.send(.didDisappear)
        }
    }

    private var newPasswordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.newPassword,
                send: { .didChangeNewPassword($0) }
            ),
            isFirstResponder: $isNewPasswordFieldFirstResponder,
            isError: .constant(false),
            title: LocalizedString.TextFieldTitle.newPassword,
            configuration: {
                $0.isSecureTextEntry = !isPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.textContentType = .password
            },
            onPaddingTapped: {
                isNewPasswordFieldFirstResponder = true
                isConfirmNewPasswordFieldFirstResponder = false
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = true
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
        .onChange(of: viewStore.newPassword) { _ in
            viewStore.send(.validatePasswordStrength)
            // TODO: wait for design
            print("TTT \(viewStore.passwordStrength)")
        }
    }

    private var confirmNewPasswordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.confirmNewPassword,
                send: { .didChangeConfirmNewPassword($0) }
            ),
            isFirstResponder: $isConfirmNewPasswordFieldFirstResponder,
            isError: viewStore.binding(
                get: { $0.newPassword != $0.confirmNewPassword },
                send: .none
            ),
            title: LocalizedString.TextFieldTitle.confirmNewPassword,
            configuration: {
                $0.isSecureTextEntry = !isConfirmNewPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.textContentType = .password
            },
            errorMessage: LocalizedString.confirmPasswordNotMatch,
            onPaddingTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = true
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = false
            },
            trailingAccessoryView: {
                Button(
                    action: { isConfirmNewPasswordVisible.toggle() },
                    label: {
                        Image(systemName: isConfirmNewPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color.secureFieldEyeSymbol)
                    }
                )
            }
        )
    }
}

#if DEBUG
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(
            store: .init(
                initialState: .init(),
                reducer: resetPasswordReducer,
                environment: .init()
            )
        )
    }
}
#endif
