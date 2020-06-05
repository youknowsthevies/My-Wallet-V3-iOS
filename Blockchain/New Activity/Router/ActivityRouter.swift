//
//  ActivityRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import NetworkKit
import PlatformKit
import PlatformUIKit
import SafariServices

final class ActivityRouter: ActivityRouterAPI {

    weak var navigationControllerAPI: NavigationControllerAPI?
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!

    private let serviceContainer: ActivityServiceContaining
    private let blockchainAPI: BlockchainAPI

    init(topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared,
         container: ActivityServiceContaining,
         blockchainAPI: BlockchainAPI = .shared) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.serviceContainer = container
        self.blockchainAPI = blockchainAPI
    }
    
    func showWalletSelectionScreen() {
        let presenter = WalletPickerScreenPresenter(
            interactor: .init(
                balanceProviding: serviceContainer.balanceProviding,
                selectionService: serviceContainer.selectionServiceAPI
            )
        )
        let controller = WalletPickerScreenViewController(presenter: presenter)
        present(viewController: controller)
    }
    
    func showTransactionScreen(with event: ActivityItemEvent) {
        let controller = DetailsScreenViewController(
            presenter: ActivityDetailsPresenterFactory.presenter(for: event, router: self)
        )
        present(viewController: controller, using: .modalOverTopMost)
    }
    
    func showBlockchainExplorer(for event: TransactionalActivityItemEvent) {
        guard let url = URL(string: blockchainAPI.transactionDetailURL(for: event.identifier, cryptoCurrency: event.currency))
            else { return }
        let controller = SFSafariViewController(url: url)
        controller.modalPresentationStyle = .overFullScreen
        topMostViewControllerProvider.topMostViewController?.present(
            controller,
            animated: true,
            completion: nil
        )
    }
}
