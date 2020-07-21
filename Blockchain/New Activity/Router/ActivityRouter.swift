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
        let balanceProviding = serviceContainer.balanceProviding
        
        let interactor = WalletPickerScreenInteractor(
            balanceProviding: balanceProviding,
            tether: .init(balanceFetcher: balanceProviding[.crypto(.tether)], currency: .tether),
            algorand: .init(balanceFetcher: balanceProviding[.crypto(.algorand)], currency: .algorand),
            ether: .init(balanceFetcher: balanceProviding[.crypto(.ethereum)], currency: .ethereum),
            pax: .init(balanceFetcher: balanceProviding[.crypto(.pax)], currency: .pax),
            stellar: .init(balanceFetcher: balanceProviding[.crypto(.stellar)], currency: .stellar),
            bitcoin: .init(balanceFetcher: balanceProviding[.crypto(.bitcoin)], currency: .bitcoin),
            bitcoinCash: .init(balanceFetcher: balanceProviding[.crypto(.bitcoinCash)], currency: .bitcoinCash),
            selectionService: serviceContainer.selectionServiceAPI
        )
        
        let presenter = WalletPickerScreenPresenter(interactor: interactor)
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
        guard
            let urlString = blockchainAPI.transactionDetailURL(for: event.identifier, cryptoCurrency: event.currency),
            let url = URL(string: urlString)
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
