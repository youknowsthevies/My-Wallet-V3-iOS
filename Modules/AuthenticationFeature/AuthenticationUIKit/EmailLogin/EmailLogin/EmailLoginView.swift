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
        self.viewStore = ViewStore(self.store)
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

                Spacer()

                PrimaryButton(title: EmailLoginString.Button._continue) {
                    viewStore.send(.sendDeviceVerificationEmail)
                }
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 34, trailing: 24))
                .disabled(!viewStore.isEmailValid)

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
            .navigationBarTitle(EmailLoginString.navigationTitle)
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
            .updateNavigationBarStyle()
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
                Store(initialState: .init(),
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
