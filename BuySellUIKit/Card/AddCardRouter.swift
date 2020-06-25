//
//  AddCardRouter.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

public final class AddCardRouter: PlatformUIKit.Router {
    
    // MARK: - Types
    
    public enum RoutingType {
        case modal
        case embed(inside: NavigationControllerAPI)
    }
    
    // MARK: - `Router` Properties
    
    public weak var topMostViewControllerProvider: TopMostViewControllerProviding!
    public weak var navigationControllerAPI: NavigationControllerAPI?
    
    let stateService: AddCardStateService
    
    // MARK: - Private Properties

    private let routingType: RoutingType
    private let cardServiceProvider: CardServiceProviderAPI
    private let simpleBuyServiceProvider: ServiceProviderAPI
    private let utilityProvider: UIUtilityProviderAPI
    private let recordingProvider: RecordingProviderAPI
    private let disposeBag = DisposeBag()
    
    public init(stateService: AddCardStateService,
                cardServiceProvider: CardServiceProviderAPI,
                simpleBuyServiceProvider: ServiceProviderAPI,
                recordingProvider: RecordingProviderAPI,
                utilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
                routingType: RoutingType = .modal,
                topMostViewControllerProvider: TopMostViewControllerProviding = UIApplication.shared) {
        self.stateService = stateService
        self.routingType = routingType
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.cardServiceProvider = cardServiceProvider
        self.recordingProvider = recordingProvider
        self.simpleBuyServiceProvider = simpleBuyServiceProvider
        self.utilityProvider = utilityProvider
    }
    
    /// Entry method to card addition / editing that should be called once
    public func setup() {
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
            data: data,
            eventRecorder: recordingProvider.analytics
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        present(viewController: viewController)
    }
    
    private func showCardDetailsScreen() {
        let interactor = CardDetailsScreenInteractor(
            paymentMethodsService: simpleBuyServiceProvider.paymentMethods,
            cardListService: cardServiceProvider.cardList
        )
        let presenter = CardDetailsScreenPresenter(
            stateService: stateService,
            interactor: interactor,
            eventRecorder: recordingProvider.analytics,
            messageRecorder: recordingProvider.message
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
            stateService: stateService,
            eventRecorder: recordingProvider.analytics,
            messageRecorder: recordingProvider.message
        )
        let viewController = BillingAddressScreenViewController(
            presenter: presenter,
            alertViewPresenter: utilityProvider.alert
        )
        present(viewController: viewController)
    }
}
