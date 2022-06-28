import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import SwiftUI

public struct UserDeletionState: Equatable, NavigationState {
    public var route: RouteIntent<UserDeletionRoute>?

    public init(
        route: RouteIntent<UserDeletionRoute>? = nil
    ) {
        self.route = route
    }
}

extension UserDeletionState {
    var externalLinks: ExternalLinks {
        .init()
    }

    struct ExternalLinks {
        var dataRetention: URL {
            URL(string: "https://www.blockchain.com/legal/privacy")!
        }

        var needHelp: URL {
            URL(string: "https://blockchain.zendesk.com/hc/en-us/articles/5159481570076")!
        }
    }
}

public enum UserDeletionRoute: NavigationRoute, Hashable {
    case showConfirmationView(
        userDeletionRepository: UserDeletionRepositoryAPI,
        dismissFlow: () -> Void,
        logoutAndForgetWallet: () -> Void
    )

    public func destination(in store: Store<UserDeletionState, UserDeletionAction>) -> some View {
        switch self {
        case .showConfirmationView(let userDeletionRepository, let dismissFlow, let logoutAndForgetWallet):
            return DeletionConfirmView(store: .init(
                initialState: DeletionConfirmState(),
                reducer: DeletionConfirmModule.reducer,
                environment: .init(
                    mainQueue: .main,
                    userDeletionRepository: userDeletionRepository,
                    dismissFlow: dismissFlow,
                    logoutAndForgetWallet: logoutAndForgetWallet
                )
            )
            )
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .showConfirmationView:
            hasher.combine("showConfirmationView")
        }
    }

    public static func == (lhs: UserDeletionRoute, rhs: UserDeletionRoute) -> Bool {
        switch (lhs, rhs) {
        case (.showConfirmationView, .showConfirmationView):
            return true
        }
    }
}
