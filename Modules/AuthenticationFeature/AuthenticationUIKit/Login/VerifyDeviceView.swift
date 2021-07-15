// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import PlatformUIKit
import SwiftUI
import UIComponentsKit

typealias VerifyDeviceViewString = LocalizationConstants.AuthenticationKit.VerifyDevice

public struct VerifyDeviceView: View {
    let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject var viewStore: ViewStore<VerifyDeviceViewState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
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

            SecondaryButton(title: VerifyDeviceViewString.Button.sendAgain) {
                viewStore.send(.verifyRecaptcha)
            }
            .padding(.bottom, 10)

            PrimaryButton(title: VerifyDeviceViewString.Button.openEmail) {
                UIApplication.shared.openMailApplication()
            }

            NavigationLink(
                destination: CredentialsView(store: store),
                isActive: viewStore.binding(
                    get: \.isPasswordLoginVisible,
                    send:  WelcomeAction.setPasswordLoginVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 247, leading: 24, bottom: 58, trailing: 24))
        .alert(self.store.scope(state: \.alert), dismiss: .alert(.dismiss))
    }
}

struct VerifyDeviceViewState: Equatable {
    var isPasswordLoginVisible: Bool

    init(state: WelcomeState) {
        isPasswordLoginVisible = state.isPasswordLoginVisible
    }
}

#if DEBUG
struct VerifyDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyDeviceView(
            store:
                Store(initialState: WelcomeState(),
                      reducer: welcomeReducer,
                      environment: .init(
                        mainQueue: .main,
                        buildVersionProvider: { "test version" },
                        authenticationService: NoOpAuthenticationService()
                      )
                )
        )
    }
}
#endif
