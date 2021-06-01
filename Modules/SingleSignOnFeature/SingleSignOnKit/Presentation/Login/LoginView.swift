// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

public struct LoginView: View {
    let store: Store<SingleSignOnState, SingleSignOnAction>
    @ObservedObject var viewStore: ViewStore<LoginViewState, SingleSignOnAction>

    public init(store: Store<SingleSignOnState, SingleSignOnAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: LoginViewState.init))
    }

    public var body: some View {
        NavigationView {
            VStack {
                FormTextFieldGroup(
                    title: "Email",
                    text: .constant(""),
                    textPlaceholder: "your@email.com"
                )
                .padding(EdgeInsets(top: 34, leading: 24, bottom: 0, trailing: 24))
                Spacer()
                PrimaryButton(title: "Continue") {
                    // TODO: add continue action here
                }
                .padding(EdgeInsets(top: 0, leading: 24, bottom: 34, trailing: 24))
            }
            .navigationBarTitle("Log In", displayMode: .inline)
            .updateNavigationBarStyle()
            .trailingNavigationButton(.close) {
                viewStore.send(.setLoginVisible(false))
            }
        }
    }
}

struct LoginViewState: Equatable {
    var email: String

    init(state: SingleSignOnState) {
        self.email = state.email
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store:
                Store(initialState: SingleSignOnState(),
                      reducer: singleSignOnReducer,
                      environment: .init(
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                      )
                )
        )
    }
}
