//
//  AddCardRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class AddCardRouter: Router {
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
        
    // MARK: - Private Properties

    private let serviceProvider: AddCardServiceProvider
    private let stateService = AddCardStateService()
    private let disposeBag = DisposeBag()
    
    init(serviceProvider: AddCardServiceProvider = AddCardServiceProvider(),
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.serviceProvider = serviceProvider
    }
    
    /// Entry method to card addition / editing that should be called once
    func start() {
        stateService.action
            .bind(weak: self) { (self, action) in
                switch action {
                case .previous:
                    self.dismiss()
                case .next(to: let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
        stateService.start()
    }
    
    func next(to state: AddCardStateService.State) {
        switch state {
        case .cardDetails:
            showCardDetailsScreen()
        case .billingAddress(let cardData):
            showBillingAddressScreen(for: cardData)
        case .inactive:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Accessors
    
    private func showCardDetailsScreen() {
        let presenter = CardDetailsScreenPresenter(
            stateService: stateService
        )
        let viewController = CardDetailsScreenViewController(presenter: presenter)
        present(viewController: viewController)
    }
    
    private func showBillingAddressScreen(for cardData: CardData) {
        let selectionRouter = SelectionRouter(parent: navigationControllerAPI!)
        let interactor = BillingAddressScreenInteractor(
            cardData: cardData,
            userDataRepository: serviceProvider.dataRepository
        )
        let presenter = BillingAddressScreenPresenter(
            interactor: interactor,
            countrySelectionRouter: selectionRouter,
            stateService: stateService
        )
        let viewController = BillingAddressScreenViewController(presenter: presenter)
        present(viewController: viewController)
    }
}
