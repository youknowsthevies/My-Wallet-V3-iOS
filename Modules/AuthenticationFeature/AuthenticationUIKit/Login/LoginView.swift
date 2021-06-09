// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias LoginViewString = LocalizationConstants.AuthenticationKit.Login

public struct LoginView: View {
    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<LoginViewState, AuthenticationAction>

    public init(store: Store<AuthenticationState, AuthenticationAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: LoginViewState.init))
    }

    public var body: some View {
        NavigationView {
            VStack {
                FormTextFieldGroup(
                    title: LoginViewString.TextFieldTitle.email,
                    text: viewStore.binding(
                        get: { $0.emailAddress },
                        send: { .didChangeEmailAddress($0) }
                    ),
                    textPlaceholder: LoginViewString.TextFieldPlaceholder.email
                )
                .padding(EdgeInsets(top: 34, leading: 24, bottom: 2, trailing: 24))
                LabelledDivider(label: LoginViewString.Divider.or)
                IconButton(title: LoginViewString.Button.scanPairingCode,
                           icon: Image.ButtonIcon.qrCode) {
                    // TODO: add scan pairing code action here
                }
                .foregroundColor(.buttonPrimaryBackground)
                .padding(EdgeInsets(top: 22, leading: 24, bottom: 34, trailing: 24))
                Spacer()
                PrimaryButton(title: LoginViewString.Button._continue) {
                    viewStore.send(.setVerifyDeviceVisible(true))
                }
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 34, trailing: 24))
                .disabled(viewStore.state.emailAddress.isEmpty)
                NavigationLink(
                    destination: VerifyDeviceView(store: store),
                    isActive: viewStore.binding(
                        get: \.isVerifyDeviceVisible,
                        send:  AuthenticationAction.setVerifyDeviceVisible(_:)
                    ),
                    label: EmptyView.init
                )
            }
            .navigationBarTitle(LoginViewString.navigationTitle)
            .updateNavigationBarStyle()
            .trailingNavigationButton(.close) {
                viewStore.send(.setLoginVisible(false))
            }
        }
    }
}

struct LoginViewState: Equatable {
    var emailAddress: String
    var isVerifyDeviceVisible: Bool

    init(state: AuthenticationState) {
        self.emailAddress = state.emailAddress
        self.isVerifyDeviceVisible = state.isVerifyDeviceVisible
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store:
                Store(initialState: AuthenticationState(),
                      reducer: authenticationReducer,
                      environment: .init(
                        mainQueue: .main
                      )
                )
        )
    }
}
