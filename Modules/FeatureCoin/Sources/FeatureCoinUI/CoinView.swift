// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

public struct CoinViewState {}

public enum CoinViewAction {}

public struct CoinViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.mainQueue = mainQueue
    }
}

public let CoinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
> { _, _, _ in .none }

public struct CoinViewView: View {

    let store: Store<CoinViewState, CoinViewAction>

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
    }

    public var body: some View {
        EmptyView()
    }
}

// swiftlint:disable type_name
struct CoinViewView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CoinViewView(
                store: .init(
                    initialState: .init(),
                    reducer: CoinViewReducer,
                    environment: .init()
                )
            )
        }
    }
}
