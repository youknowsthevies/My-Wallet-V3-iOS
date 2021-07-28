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

    init(store: Store<EmailLoginState, EmailLoginAction>) {
        self.store = store
        viewStore = ViewStore(self.store)
    }

    var body: some View {
        NavigationView {
            VStack {
                FormTextFieldGroup(
                    title: EmailLoginString.TextFieldTitle.email,
                    text: viewStore.binding(
                        get: { $0.emailAddress },
                        send: { .didChangeEmailAddress($0) }
                    ),
                    textPlaceholder: EmailLoginString.TextFieldPlaceholder.email,
                    error: { _ in !viewStore.isEmailValid && !viewStore.emailAddress.isEmpty },
                    errorMessage: EmailLoginString.TextFieldError.invalidEmail
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(EdgeInsets(top: 34, leading: 24, bottom: 20, trailing: 24))
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
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 34, trailing: 24))
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
        .alert(self.store.scope(state: \.emailLoginFailureAlert), dismiss: .emailLoginFailureAlert(.dismiss))
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
