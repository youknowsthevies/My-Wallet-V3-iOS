import ComposableArchitecture
import ComposableNavigation
import FeatureUserDeletionDomain
import Localization
import SwiftUI

private typealias LocalizedString = LocalizationConstants.UserDeletion.ConfirmationScreen

public enum FormField {
    case confirmation
}

public struct DeletionConfirmState: Equatable, NavigationState {
    public var route: RouteIntent<UserDeletionResultRoute>?

    @BindableState var textFieldText: String = ""
    @BindableState public var firstResponder: FormField?

    var isLoading: Bool = false
    var isConfirmationInputValid: Bool = false
    var shouldShowInvalidInputUI: Bool = false

    mutating func validateConfirmationInputField() {
        // isConfirmationInputValid
        isConfirmationInputValid = textFieldText ==
            LocalizedString.textField.placeholder

        // shouldShowInvalidInputUI
        let placeholder = LocalizedString.textField.placeholder
        let userIsTyping = firstResponder == .confirmation
        guard userIsTyping else {
            shouldShowInvalidInputUI = !isConfirmationInputValid
            return
        }
        let textSoFar = placeholder.prefix(textFieldText.count)
        shouldShowInvalidInputUI = textSoFar != textFieldText
    }

    public init(
        route: RouteIntent<UserDeletionResultRoute>? = nil
    ) {
        self.route = route
    }

    public static func == (
        lhs: DeletionConfirmState,
        rhs: DeletionConfirmState
    ) -> Bool {
        lhs.isLoading == rhs.isLoading &&
            lhs.route == rhs.route &&
            lhs.textFieldText == rhs.textFieldText &&
            lhs.firstResponder == rhs.firstResponder &&
            lhs.isConfirmationInputValid && rhs.isConfirmationInputValid &&
            lhs.shouldShowInvalidInputUI && rhs.shouldShowInvalidInputUI
    }
}

public enum UserDeletionResultRoute: NavigationRoute, Hashable {
    case showResultScreen(
        success: Bool,
        dismissFlow: () -> Void,
        logoutAndForgetWallet: () -> Void
    )

    public func destination(in store: Store<DeletionConfirmState, DeletionConfirmAction>) -> some View {
        switch self {
        case let .showResultScreen(success, dismissFlow, logoutAndForgetWallet):
            return DeletionResultView(store: .init(
                initialState: .init(success: success),
                reducer: DeletionResultModule.reducer,
                environment: .init(
                    mainQueue: .main,
                    dismissFlow: dismissFlow,
                    logoutAndForgetWallet: logoutAndForgetWallet
                )
            ))
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .showResultScreen:
            hasher.combine("showResultScreen")
        }
    }

    public static func == (
        lhs: UserDeletionResultRoute,
        rhs: UserDeletionResultRoute
    ) -> Bool {
        switch (lhs, rhs) {
        case (.showResultScreen, .showResultScreen):
            return true
        }
    }
}
