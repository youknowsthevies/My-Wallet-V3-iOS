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
                .font(Font(weight: .semibold, size: 20))
                .textStyle(.title)
                .padding(EdgeInsets(top: 24, leading: 0, bottom: 8, trailing: 0))
            Text(VerifyDeviceViewString.description)
                .font(Font(weight: .medium, size: 16))
                .textStyle(.subheading)
            Spacer()
            PrimaryButton(title: VerifyDeviceViewString.Button.openEmail) {
                // TODO: add open email action here
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
            SecondaryButton(title: VerifyDeviceViewString.Button.sendAgain) {
                // TODO: add send again action here
            }
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 247, leading: 24, bottom: 56, trailing: 24))
    }
}

struct VerifyDeviceViewState: Equatable {
    init(state: AuthenticationState) {
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
