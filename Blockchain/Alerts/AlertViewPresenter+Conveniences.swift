// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

extension AlertViewPresenter {

    /// Asks permission from the user to use values in the keychain. This is typically invoked
    /// on a new installation of the app (meaning the user previously installed the app, deleted it,
    /// and downloaded the app again).
    ///
    /// - Parameter handler: the AlertConfirmHandler invoked when the user **does not** grant permission
    func alertUserAskingToUseOldKeychain(handler: @escaping AlertViewContent.Action) {
        Execution.MainQueue.dispatch {
            let alert = UIAlertController(
                title: LocalizationConstants.Onboarding.askToUserOldWalletTitle,
                message: LocalizationConstants.Onboarding.askToUserOldWalletMessage,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.Onboarding.createNewWallet, style: .cancel, handler: handler)
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.Onboarding.loginExistingWallet, style: .default)
            )
            self.standardNotify(alert: alert)
        }
    }

    /// Shows the user an alert that the app failed to read values from the keychain.
    /// Upon confirming on the presented alert, the app will terminate.
    @objc func showKeychainReadError() {
        standardNotify(
            title: LocalizationConstants.Authentication.failedToLoadWallet,
            message: LocalizationConstants.Errors.errorLoadingWalletIdentifierFromKeychain
        ) { _ in
            // Close App
            UIApplication.shared.suspendApp()
        }
    }

    @objc func checkAndWarnOnJailbrokenPhones() {
        guard UIDevice.current.isUnsafe() else {
            return
        }
        standardNotify(
            title: LocalizationConstants.Errors.unsafeDeviceWarningMessage,
            message: LocalizationConstants.Errors.warning
        )
    }

    /// Shows the site maintenance error message from `walletOptions` if any.
    ///
    /// - Parameter walletOptions: the WalletOptions
    func showMaintenanceError(from walletOptions: WalletOptions) {
        guard walletOptions.downForMaintenance else {
            Logger.shared.info(
                "Not showing site maintenance alert. WalletOptions `downForMaintenance` flag is not set."
            )
            return
        }
        let message = walletOptions.mobileInfo?.message ?? LocalizationConstants.Errors.siteMaintenanceError
        AlertViewPresenter.shared.standardError(message: message)
    }

    /// Displays an alert to the user if the wallet object contains a value from `Wallet.getMobileMessage`.
    /// Otherwise, if there is no value, no such alert will be presented.
    @objc func showMobileNoticeIfNeeded() {
        guard let message = WalletManager.shared.wallet.getMobileMessage(), message.count > 0 else {
            return
        }

        standardNotify(
            title: LocalizationConstants.information,
            message: message
        )
    }
}
