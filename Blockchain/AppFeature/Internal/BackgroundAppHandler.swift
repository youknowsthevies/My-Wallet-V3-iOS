// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import SettingsKit
import ToolKit

final class BackgroundAppHandler {
    let backgroundTaskTimer = BackgroundTaskTimer(
        invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier(
            identifier: UIBackgroundTaskIdentifier.invalid
        )
    )

    private let appCoordinator: AppCoordinator
    private let urlSession: URLSession

    init(appCoordinator: AppCoordinator = .shared,
         urlSession: URLSession = resolve()) {
        self.appCoordinator = appCoordinator
        self.urlSession = urlSession
    }

    func handleAppEnteredBackground(_ application: UIApplication) {
        backgroundTaskTimer.begin(application) { [weak self] in
            self?.delayedApplicationDidEnterBackground(application)
        }
    }

    func handleAppEnteredForeground(_ application: UIApplication) {
        backgroundTaskTimer.stop(application)
    }

    func delayedApplicationDidEnterBackground(_ application: UIApplication) {
        // Wallet-related background actions

        // TODO: This should be moved into a component that performs actions to the wallet
        // on different lifecycle events (e.g. "WalletAppLifecycleListener")
        let appSettings = BlockchainSettings.App.shared
        let wallet = WalletManager.shared.wallet

        NotificationCenter.default.post(name: Constants.NotificationKeys.appEnteredBackground, object: nil)

        if wallet.isInitialized() {
            if appSettings.guid != nil && appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        // UI-related background actions
        ModalPresenter.shared.closeAllModals()

        /// TODO: Remove this - we don't want any such logic in `AppDelegate`
        /// We have to make sure the 2FA alerts (email / auth app) are still showing
        /// when the user goes back to foreground
        if appCoordinator.onboardingRouter.state != .pending2FA {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
        }

        appCoordinator.cleanupOnAppBackgrounded()
        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        urlSession.reset {
            Logger.shared.debug("URLSession reset completed.")
        }
    }

}
