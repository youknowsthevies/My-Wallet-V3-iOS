// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppUI
import UIComponentsKit

/// Provides a prompt mechanism for second password
protocol SecondPasswordHelperAPI: AnyObject {
    ///   - type: The type of the screen
    ///   - confirmHandler: Confirmation handler, receives the password
    ///   - dismissHandler: Dismiss handler (optional - defaults to `nil`)
    func showPasswordScreen(
        type: PasswordScreenType,
        confirmHandler: @escaping (String) -> Void,
        dismissHandler: (() -> Void)?
    )
}

protocol SecondPasswordPresenterHelper {
    /// Boolean to determine whether the second password screen is displayed or not
    var isShowingSecondPasswordScreen: Bool { get set }
}

/// A temporary helper class that acts as a coordinator/router for displaying the `SecondPasswordController` when needed
final class SecondPasswordHelper: SecondPasswordHelperAPI, SecondPasswordPresenterHelper {

    // MARK: - Private Properties

    var isShowingSecondPasswordScreen: Bool = false

    // MARK: - SecondPasswordPrompterAPI

    func showPasswordScreen(
        type: PasswordScreenType,
        confirmHandler: @escaping (String) -> Void,
        dismissHandler: (() -> Void)? = nil
    ) {
        guard !isShowingSecondPasswordScreen else { return }
        guard let parent = UIApplication.shared.topMostViewController else {
            return
        }
        isShowingSecondPasswordScreen = true

        let navigationController = UINavigationController()

        let confirm: (String) -> Void = { [weak navigationController] password in
            navigationController?.dismiss(animated: true) {
                confirmHandler(password)
            }
        }

        let dismiss: (() -> Void) = { [weak navigationController] in
            navigationController?.dismiss(animated: true) {
                dismissHandler?()
            }
        }

        // loadingViewPresenter.hide()
        let interactor = PasswordScreenInteractor(type: type)
        let presenter = PasswordScreenPresenter(
            interactor: interactor,
            confirmHandler: confirm,
            dismissHandler: dismiss
        )
        let viewController = PasswordViewController(presenter: presenter)
        navigationController.viewControllers = [viewController]
        parent.present(navigationController, animated: true, completion: nil)
    }
}
