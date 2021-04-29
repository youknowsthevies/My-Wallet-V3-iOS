// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import TransactionKit

final class ReceiveRouter: ReceiveRouterAPI {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let navigationRouter: NavigationRouterAPI

    init(navigationRouter: NavigationRouterAPI = NavigationRouter()) {
        self.navigationRouter = navigationRouter
    }

    func presentReceiveScreen(for account: BlockchainAccount) {
        guard let account = account as? SingleAccount else {
            return
        }
        let interactor = ReceiveScreenInteractor(account: account)
        let presenter = ReceiveScreenPresenter(interactor: interactor)
        let receive = ReceiveScreenViewController(presenter: presenter)
        let nav = UINavigationController(rootViewController: receive)
        navigationRouter.present(viewController: nav)
    }

    func shareDetails(for metadata: CryptoAssetQRMetadata) {
        let displayCode = metadata.cryptoCurrency.displayCode
        let prefix = String(format: LocalizedString.Text.pleaseSendXTo, displayCode)
        let message = "\(prefix) \(metadata.address)"
        let subject = String(format: LocalizedString.Text.xPaymentRequest, displayCode)
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(subject, forKey: "subject")
        navigationRouter.present(viewController: activityViewController)
    }
}
