// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

typealias VerifyDeviceViewString = LocalizationConstants.AuthenticationKit.VerifyDevice

public struct VerifyDeviceView: View {
    let store: Store<AuthenticationState, AuthenticationAction>
    @ObservedObject var viewStore: ViewStore<VerifyDeviceViewState, AuthenticationAction>

    public init(store: Store<AuthenticationState, AuthenticationAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: VerifyDeviceViewState.init))
    }

    public var body: some View {
        VStack {
            Image.CircleIcon.verifyDevice
                .frame(width: 72, height: 72)

            Text(VerifyDeviceViewString.title)
                .textStyle(.title)
                .padding(.top, 16)

            Text(VerifyDeviceViewString.description)
                .font(Font(weight: .medium, size: 16))
                .foregroundColor(.textSubheading)
                .lineSpacing(4)

            Spacer()

            PrimaryButton(title: VerifyDeviceViewString.Button.openEmail) {
                viewStore.send(.setPasswordLoginVisible(true))
            }
            .padding(.bottom, 10)

            SecondaryButton(title: VerifyDeviceViewString.Button.sendAgain) {
                // Add send again action here
            }

            NavigationLink(
                destination: CredentialsView(store: store),
                isActive: viewStore.binding(
                    get: \.isPasswordLoginVisible,
                    send:  AuthenticationAction.setPasswordLoginVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 247, leading: 24, bottom: 58, trailing: 24))
    }
}

struct VerifyDeviceViewState: Equatable {
    var isPasswordLoginVisible: Bool

    init(state: AuthenticationState) {
        isPasswordLoginVisible = state.isPasswordLoginVisible
    }
}

struct VerifyDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyDeviceView(
            store:
                Store(initialState: AuthenticationState(),
                      reducer: authenticationReducer,
                      environment: .init(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                      )
                )
        )
    }
}
