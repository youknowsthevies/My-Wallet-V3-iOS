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
import DIKit

final class ActivityRouter: ActivityRouterAPI {
    
    private let serviceContainer: ActivityServiceContaining
    private let blockchainAPI: BlockchainAPI
    private let navigationRouter: NavigationRouterAPI

    private let enabledCurrenciesService: EnabledCurrenciesService
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         enabledCurrenciesService: EnabledCurrenciesService = resolve(),
         container: ActivityServiceContaining,
         blockchainAPI: BlockchainAPI = .shared) {
        self.navigationRouter = navigationRouter
        self.serviceContainer = container
        self.enabledCurrenciesService = enabledCurrenciesService
        self.blockchainAPI = blockchainAPI
    }
    
    func showWalletSelectionScreen() {
        let balanceProviding = serviceContainer.balanceProviding

        func cellInteractorProvider(for cryptoCurrency: CryptoCurrency) -> WalletPickerCellInteractorProviding {
            WalletPickerCellInteractorProvider(
                balanceFetcher: balanceProviding[.crypto(cryptoCurrency)],
                currency: cryptoCurrency,
                isEnabled: enabledCurrenciesService.allEnabledCryptoCurrencies.contains(cryptoCurrency)
            )
        }
        let interactor = WalletPickerInteractor(
            balanceProviding: balanceProviding,
            tether: cellInteractorProvider(for: .tether),
            algorand: cellInteractorProvider(for: .algorand),
            ethereum: cellInteractorProvider(for: .ethereum),
            pax: cellInteractorProvider(for: .pax),
            stellar: cellInteractorProvider(for: .stellar),
            bitcoin: cellInteractorProvider(for: .bitcoin),
            bitcoinCash: cellInteractorProvider(for: .bitcoinCash),
            selectionService: serviceContainer.selectionServiceAPI
        )
        
        let presenter = WalletPickerScreenPresenter(showTotalBalance: true, interactor: interactor)
        let controller = WalletPickerScreenViewController(presenter: presenter)
        navigationRouter.present(viewController: controller)
    }
    
    func showTransactionScreen(with event: ActivityItemEvent) {
        let controller = DetailsScreenViewController(
            presenter: ActivityDetailsPresenterFactory.presenter(for: event, router: self)
        )
        navigationRouter.present(viewController: controller, using: .modalOverTopMost)
    }
    
    func showBlockchainExplorer(for event: TransactionalActivityItemEvent) {
        guard
            let urlString = blockchainAPI.transactionDetailURL(for: event.identifier, cryptoCurrency: event.currency),
            let url = URL(string: urlString)
            else { return }
        let controller = SFSafariViewController(url: url)
        controller.modalPresentationStyle = .overFullScreen
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(
            controller,
            animated: true,
            completion: nil
        )
    }
    
    func showActivityShareSheet(_ event: ActivityItemEvent) {
        let viewModel = ActivityMessageViewModel(
            event: event,
            qrCodeAPI: QRCodeWrapper()
        )
        guard let model = viewModel else { return }
        let view = ActivityMessageView(
            frame: .init(
                origin: .zero,
                size: .init(
                    width: 275.0,
                    height: 300.0
                )
            )
        )
        view.viewModel = model
        
        guard let image = view.imageRepresentation else { return }
        let controller = UIActivityViewController(
            activityItems: [(image.pngData() ?? Data())],
            applicationActivities: nil
        )
        topMostViewControllerProvider.topMostViewController?.present(controller, animated: true, completion: nil)
    }
}
