// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import SettingsKit

@available(*, deprecated, message: "This is a temporary class that handles a deep link url, marking as deprecated and it will be replaced")
final class DeeplinkAppHandler {

    private let appCoordinator: AppCoordinator
    private lazy var bitpayRouter = BitPayLinkRouter()
    private lazy var deepLinkRouter = DeepLinkRouter()

    init(appCoordinator: AppCoordinator = .shared) {
        self.appCoordinator = appCoordinator
    }

    func handle(url: URL) -> Bool {
        let urlString = url.absoluteString

        guard BlockchainSettings.App.shared.isPinSet else {
            if "\(AssetConstants.URLSchemes.blockchainWallet)loginAuthorized" == urlString {
                // TODO: Link to manual pairing
                appCoordinator.onboardingRouter.start()
                return true
            }
            return false
        }

        guard let urlScheme = url.scheme else {
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchainWallet {
            // Redirect from browser to app - do nothing.
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchain {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            return true
        }

        let isInitialized = WalletManager.shared.wallet.isInitialized()
        let hasGuid = BlockchainSettings.App.shared.guid != nil
        let hasSharedKey = BlockchainSettings.App.shared.sharedKey != nil
        let authenticated = isInitialized && hasGuid && hasSharedKey

        if BitPayLinkRouter.isBitPayURL(url) {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            BitpayService.shared.contentRelay.accept(url)
            guard authenticated else { return true }
            return bitpayRouter.routeIfNeeded()
        }

        // Handle "bitcoin://" scheme
        if let bitcoinUrlPayload = BitcoinURLPayload(url: url) {

            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)

            AuthenticationCoordinator.shared.postAuthenticationRoute = .sendCoins

            appCoordinator.tabControllerManager?.setupBitcoinPaymentFromURLHandler(
                with: bitcoinUrlPayload.amount,
                address: bitcoinUrlPayload.address
            )

            return true
        }

        if authenticated {
            ModalPresenter.shared.closeModal(withTransition: CATransitionType.fade.rawValue)
            deepLinkRouter.routeIfNeeded()
            return true
        }

        return true
    }
}
