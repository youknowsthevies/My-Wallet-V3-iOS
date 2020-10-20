//
//  ActivityRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 16/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ActivityKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SafariServices

final class ActivityRouter: ActivityRouterAPI {
    
    private let serviceContainer: ActivityServiceContaining
    private let transactionDetailService: TransactionDetailServiceAPI
    private let navigationRouter: NavigationRouterAPI

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    
    init(navigationRouter: NavigationRouterAPI = NavigationRouter(),
         enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
         container: ActivityServiceContaining = resolve(),
         transactionDetailService: TransactionDetailServiceAPI = resolve()) {
        self.navigationRouter = navigationRouter
        self.serviceContainer = container
        self.enabledCurrenciesService = enabledCurrenciesService
        self.transactionDetailService = transactionDetailService
    }

    func showWalletSelectionScreen() {
        let interactor = AccountPickerScreenInteractor(
            singleAccountsOnly: false,
            action: .viewActivity,
            selectionService: serviceContainer.accountSelectionService
        )
        let presenter = AccountPickerScreenPresenter(
            interactor: interactor,
            navigationModel: ScreenNavigationModel.AccountPicker.modal
        )
        let controller = AccountPickerScreenModalViewController(presenter: presenter)
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
            let urlString = transactionDetailService.transactionDetailURL(for: event.identifier, cryptoCurrency: event.currency),
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
            event: event
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
        guard let root = navigationRouter.topMostViewControllerProvider.topMostViewController else { return }
        let controller = UIActivityViewController(
            activityItems: [ImageActivityItemSource(image: image)],
            applicationActivities: nil
        )
        
        root.present(controller, animated: true, completion: nil)
    }
}
