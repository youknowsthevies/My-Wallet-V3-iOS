// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import TransactionKit

final class ReceiveRouter: ReceiveRouterAPI {
    private typealias LocalizedString = LocalizationConstants.Receive

    private let navigationRouter: NavigationRouterAPI
    
    private let webViewService: WebViewServiceAPI
    
    private let disposeBag = DisposeBag()

    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         webViewService: WebViewServiceAPI = resolve()) {
        self.navigationRouter = navigationRouter
        self.webViewService = webViewService
    }

    func presentReceiveScreen(for account: BlockchainAccount) {
        guard let account = account as? SingleAccount else {
            return
        }
        let interactor = ReceiveScreenInteractor(account: account)
        let presenter = ReceiveScreenPresenter(interactor: interactor)
        let receive = ReceiveScreenViewController(presenter: presenter)
        let nav = UINavigationController(rootViewController: receive)
        presenter.webViewLaunchRelay
            .bind { [weak self] url in
                self?.webViewService.openSafari(url: url, from: receive)
            }
            .disposed(by: disposeBag)
        navigationRouter.present(viewController: nav)
    }

    func shareDetails(for metadata: CryptoAssetQRMetadata) {
        let displayCode = metadata.cryptoCurrency.displayCode
        let prefix = String(format: LocalizedString.Text.pleaseSendXTo, displayCode)
        let message = "\(prefix) \(metadata.absoluteString)"
        let subject = String(format: LocalizedString.Text.xPaymentRequest, displayCode)
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.assignToContact, .addToReadingList, .postToFacebook]
        activityViewController.setValue(subject, forKey: "subject")
        navigationRouter.present(viewController: activityViewController)
    }
}
