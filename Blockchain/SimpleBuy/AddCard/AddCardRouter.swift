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
    
    // MARK: - Types
    
    enum RoutingType {
        case modal
        case embed(inside: NavigationControllerAPI)
    }
    
    // MARK: - `Router` Properties
    
    weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    weak var navigationControllerAPI: NavigationControllerAPI?
    
    let stateService: AddCardStateService
    
    // MARK: - Private Properties

    private let routingType: RoutingType
    private let cardServiceProvider: CardServiceProviderAPI
    private let simpleBuyServiceProvider: SimpleBuyServiceProviderAPI
    private let disposeBag = DisposeBag()
    
    init(stateService: AddCardStateService,
         cardServiceProvider: CardServiceProviderAPI = CardServiceProvider.default,
         simpleBuyServiceProvider: SimpleBuyServiceProviderAPI = SimpleBuyServiceProvider.default,
         routingType: RoutingType = .modal,
         topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared) {
        self.stateService = stateService
        self.routingType = routingType
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.cardServiceProvider = cardServiceProvider
        self.simpleBuyServiceProvider = simpleBuyServiceProvider
    }
    
    /// Entry method to card addition / editing that should be called once
    func setup() {
        // Embed the entire flow in another navigation controller
        // instead of generating one of its own
        if case .embed(inside: let navigationController) = routingType {
            navigationControllerAPI = navigationController
        }
        stateService.action
            .bind(weak: self) { (self, action) in
                switch action {
                case .previous(from: let state):
                    self.previous(from: state)
                case .next(to: let state):
                    self.next(to: state)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - State Routing
    
    private func previous(from state: AddCardStateService.State) {
        switch state {
        case .cardDetails:
            dismiss(completion: nil)
        default:
            dismiss()
        }
    }
        
    private func next(to state: AddCardStateService.State) {
        switch state {
        case .cardDetails:
            showCardDetailsScreen()
        case .billingAddress(let cardData):
            showBillingAddressScreen(for: cardData)
        case .authorization(let data):
            showAuthorizationScreen(for: data)
        case .pendingCardState(cardId: let cardId):
            showPendingCardStateScreen(for: cardId)
        case .completed, .inactive:
            navigationControllerAPI?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Accessors
    
    private func showPendingCardStateScreen(for cardId: String) {
        let interactor = PendingCardStatusInteractor(
            cardId: cardId,
            activationService: cardServiceProvider.cardActivation,
            paymentMethodTypesService: simpleBuyServiceProvider.paymentMethodTypes
        )
        let presenter = PendingCardStatusPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        present(viewController: viewController)
    }
    
    private func showAuthorizationScreen(for data: PartnerAuthorizationData) {
        let presenter = CardAuthorizationScreenPresenter(
            stateService: stateService,
            data: data
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        present(viewController: viewController)
    }
    
    private func showCardDetailsScreen() {
        let interactor = CardDetailsScreenInteractor(
            paymentMethodsService: simpleBuyServiceProvider.paymentMethods
        )
        let presenter = CardDetailsScreenPresenter(
            stateService: stateService,
            interactor: interactor
        )
        let viewController = CardDetailsScreenViewController(presenter: presenter)
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }
        present(viewController: viewController)
    }
    
    private func showBillingAddressScreen(for cardData: CardData) {
        let selectionRouter = SelectionRouter(parent: navigationControllerAPI!)
        let interactor = BillingAddressScreenInteractor(
            cardData: cardData,
            service: cardServiceProvider.cardUpdate,
            userDataRepository: cardServiceProvider.dataRepository
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
