// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

typealias EmailLoginString = LocalizationConstants.AuthenticationKit.EmailLogin

struct EmailLoginView: View {

    private let store: Store<EmailLoginState, EmailLoginAction>
    @ObservedObject private var viewStore: ViewStore<EmailLoginState, EmailLoginAction>

    @State private var isEmailFieldFirstResponder: Bool = true

    init(store: Store<EmailLoginState, EmailLoginAction>) {
        self.store = store
        viewStore = ViewStore(self.store)
    }

    var body: some View {
        NavigationView {
            VStack {
                FormTextFieldGroup(
                    text: viewStore.binding(
                        get: { $0.emailAddress },
                        send: { .didChangeEmailAddress($0) }
                    ),
                    isFirstResponder: $isEmailFieldFirstResponder,
                    isError: viewStore.binding(
                        get: { !$0.isEmailValid && !$0.emailAddress.isEmpty },
                        send: .none
                    ),
                    title: EmailLoginString.TextFieldTitle.email,
                    configuration: {
                        $0.autocorrectionType = .no
                        $0.autocapitalizationType = .none
                        $0.textContentType = .emailAddress
                        $0.keyboardType = .emailAddress
                        $0.placeholder = EmailLoginString.TextFieldPlaceholder.email
                        $0.returnKeyType = .done
                        $0.enablesReturnKeyAutomatically = true
                    },
                    errorMessage: EmailLoginString.TextFieldError.invalidEmail,
                    onPaddingTapped: {
                        self.isEmailFieldFirstResponder = true
                    },
                    onReturnTapped: {
                        self.isEmailFieldFirstResponder = false
                    }
                )
                .padding(.top, 34)
                .padding(.bottom, 20)
                .disabled(viewStore.isLoading)
                .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.emailGroup)

                Spacer()

                PrimaryButton(
                    title: EmailLoginString.Button._continue,
                    action: {
                        viewStore.send(.sendDeviceVerificationEmail)
                    },
                    loading: viewStore.binding(get: \.isLoading, send: { _ in .none })
                )
                .padding(.bottom, 34)
                .disabled(!viewStore.isEmailValid)
                .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.continueButton)

                NavigationLink(
                    destination: IfLetStore(
                        store.scope(
                            state: \.verifyDeviceState,
                            action: EmailLoginAction.verifyDevice
                        ),
                        then: VerifyDeviceView.init(store:)
                    ),
                    isActive: viewStore.binding(
                        get: \.isVerifyDeviceScreenVisible,
                        send: EmailLoginAction.setVerifyDeviceScreenVisible(_:)
                    ),
                    label: EmptyView.init
                )
            }
            .padding([.leading, .trailing], 24)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(EmailLoginString.navigationTitle)
                        .font(Font(weight: .semibold, size: 20))
                        .padding(.top, 15)
                        .accessibility(identifier: AccessibilityIdentifiers.EmailLoginScreen.loginTitleText)
                }
            }
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
            .whiteNavigationBarStyle()
            .hideBackButtonTitle()
        }
        .alert(self.store.scope(state: \.emailLoginFailureAlert), dismiss: .alert(.dismiss))
        .onDisappear {
            self.viewStore.send(.didDisappear)
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        EmailLoginView(
            store:
            Store(
                initialState: .init(),
                reducer: emailLoginReducer,
                environment: .init(
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    mainQueue: .main
                )
            )
        )
    }
}
#endif
