// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

/// Use this type to avoid compilation issues using SwitchStore to switch on the value of LoadingState
struct LoadingStateAlertFailureWrapperView<Success, Action, Content: View>: View {

    typealias WrappedState = LoadingState<Success, AlertState<Action>>

    let store: Store<WrappedState, Action>
    let dismiss: Action
    let content: () -> Content

    var body: some View {
        SwitchStore(store) {
            CaseLet<
                LoadingState<Success, AlertState<Action>>,
                Action,
                AlertState<Action>?,
                Action,
                AnyView
            >(state: /WrappedState.failure) { alertStore in
                AnyView(
                    content()
                        .alert(alertStore, dismiss: dismiss)
                )
            }

            Default {
                content()
            }
        }
    }
}
