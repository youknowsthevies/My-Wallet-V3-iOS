// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationUI
import FeatureTourUI
import Localization
import SwiftUI

public struct TourViewAdapter: View {

    private let store: Store<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            TourView(
                environment: TourEnvironment(
                    createAccountAction: { viewStore.send(.navigate(to: .createWallet)) },
                    restoreAction: { viewStore.send(.enter(into: .restoreWallet)) },
                    logInAction: { viewStore.send(.enter(into: .emailLogin)) }
                )
            )
        }
        .navigationRoute(in: store)
    }
}
