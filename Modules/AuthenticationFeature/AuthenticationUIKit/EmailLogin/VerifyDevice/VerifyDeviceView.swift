// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import ComposableArchitecture
import Localization
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct VerifyDeviceView: View {

    private let store: Store<VerifyDeviceState, VerifyDeviceAction>
    @ObservedObject private var viewStore: ViewStore<VerifyDeviceState, VerifyDeviceAction>

    init(store: Store<VerifyDeviceState, VerifyDeviceAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack {
            Image.CircleIcon.verifyDevice
                .frame(width: 72, height: 72)

            Text(EmailLoginString.VerifyDevice.title)
                .textStyle(.title)
                .padding(.top, 16)

            Text(EmailLoginString.VerifyDevice.description)
                .font(Font(weight: .medium, size: 16))
                .foregroundColor(.textSubheading)
                .lineSpacing(4)

            Spacer()

            SecondaryButton(title: EmailLoginString.Button.sendAgain) {
                viewStore.send(.sendDeviceVerificationEmail)
            }
            .padding(.bottom, 10)

            PrimaryButton(title: EmailLoginString.Button.openEmail) {
                UIApplication.shared.openMailApplication()
            }

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.credentialsState,
                        action: VerifyDeviceAction.credentials
                    ),
                    then: { store in
                        CredentialsView(walletInfo: viewStore.walletInfo, store: store)
                    }
                ),
                isActive: viewStore.binding(
                    get: \.isCredentialsScreenVisible,
                    send: VerifyDeviceAction.setCredentialsScreenVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .multilineTextAlignment(.center)
        .padding(EdgeInsets(top: 247, leading: 24, bottom: 58, trailing: 24))
        .onDisappear {
            viewStore.send(.didDisappear)
        }
        .alert(self.store.scope(state: \.verifyDeviceFailureAlert), dismiss: .verifyDeviceFailureAlert(.dismiss))
    }
}

#if DEBUG
struct VerifyDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyDeviceView(
            store:
            Store(
                initialState: .init(),
                reducer: verifyDeviceReducer,
                environment: .init(
                    mainQueue: .main,
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecorder()
                )
            )
        )
    }
}
#endif
