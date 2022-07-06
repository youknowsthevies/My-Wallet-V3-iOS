// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: State

public struct ConfirmationState {

    public init() {}
}

// MARK: Actions

public enum ConfirmationAction: Equatable {
    case placeholder
}

// MARK: Environment

public struct ConfirmationEnvironment {
    public init() {}
}

// MARK: Reducer

public let confirmationReducer =
    Reducer<ConfirmationState, ConfirmationAction, ConfirmationEnvironment>.combine(
        Reducer<ConfirmationState, ConfirmationAction, ConfirmationEnvironment> {
            _, action, _ in
            switch action {
            case .placeholder:
                return .none
            }
        }
    )

private typealias S = ConfirmationState
private typealias A = ConfirmationAction

// MARK: - View

public struct ConfirmationView: View {
    typealias V = ConfirmationViewState

    struct ConfirmationViewState: Equatable {
        init(_ state: ConfirmationState) {}
    }

    let store: Store<ConfirmationState, ConfirmationAction>
    @ObservedObject var viewStore: ViewStore<ConfirmationViewState, ConfirmationAction>

    public init(store: Store<ConfirmationState, ConfirmationAction>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: ConfirmationViewState.init))
    }

    public var body: some View {
        ZStack {
            Text("ConfirmationView")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: Preview

struct ConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationView(
            store: Store<ConfirmationState, ConfirmationAction>(
                initialState: ConfirmationState(),
                reducer: confirmationReducer,
                environment: ConfirmationEnvironment()
            )
        )
    }
}
