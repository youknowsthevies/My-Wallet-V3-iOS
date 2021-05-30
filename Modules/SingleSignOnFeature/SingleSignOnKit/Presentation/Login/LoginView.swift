// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct LoginViewState: Equatable {
    var email: String

    init(state: SingleSignOnState) {
        self.email = state.email
    }
}

struct LoginView: View {
    let store: Store<SingleSignOnState, SingleSignOnAction>
    @ObservedObject var viewStore: ViewStore<LoginViewState, SingleSignOnAction>

    public init(store: Store<SingleSignOnState, SingleSignOnAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: LoginViewState.init))
    }

    var body: some View {
        NavigationView {
            VStack {
                FormTextFieldGroup(
                    title: "Email",
                    text: .constant(""),
                    textPlaceholder: "your@email.com"
                )
                PrimaryButton(title: "Continue") {
                    // Action here
                }
            }
            .frame(width: 380, alignment: .center)
            .navigationBarTitle("Log In", displayMode: .inline)
            .trailingNavigationButton(.close) {
                viewStore.send(.setLoginVisible(false))
            }
        }
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
