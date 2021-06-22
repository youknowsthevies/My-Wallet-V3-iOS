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

    private let urlSession: URLSession

    init(urlSession: URLSession = resolve()) {
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
        NotificationCenter.default.post(name: Constants.NotificationKeys.appEnteredBackground, object: nil)

        // Wallet-related background actions

        let appSettings = BlockchainSettings.App.shared
        let wallet = WalletManager.shared.wallet

        if wallet.isInitialized() {
            if appSettings.guid != nil && appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        // UI-related background actions
        ModalPresenter.shared.closeAllModals()

//        if appCoordinator.onboardingRouter.state != .pending2FA {
//            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
//        }
//
//        appCoordinator.cleanupOnAppBackgrounded()
//        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        urlSession.reset {
            Logger.shared.debug("URLSession reset completed.")
        }
    }

}
