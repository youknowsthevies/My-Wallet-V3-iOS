//
//  CardComponentBuilder.swift
//  BuySellUIKit
//
//  Created by Daniel on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import ToolKit

public protocol CardComponentBuilderAPI: AnyObject {
    
    /// Builds a card details screen
    func cardDetails() -> UIViewController
    
    /// Builds a billing address screen
    func billingAddress(for cardData: CardData, navigationControllerAPI: NavigationControllerAPI) -> UIViewController
    
    /// Builds a pending card status screen (hangs until card is approved)
    func pendingCardStatus(cardId: String) -> UIViewController
    
    /// Builds a card authorization screen
    func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController
    
}

public final class CardComponentBuilder: CardComponentBuilderAPI {
    
    private let utilityProvider: UIUtilityProviderAPI
    private let recordingProvider: RecordingProviderAPI
    private let routingInteractor: CardRouterInteractor
    
    public init(routingInteractor: CardRouterInteractor,
                utilityProvider: UIUtilityProviderAPI = UIUtilityProvider.default,
                recordingProvider: RecordingProviderAPI) {
        self.routingInteractor = routingInteractor
        self.utilityProvider = utilityProvider
        self.recordingProvider = recordingProvider
    }
    
    public func cardDetails() -> UIViewController {
        let interactor = CardDetailsScreenInteractor(
            routingInteractor: routingInteractor,
            paymentMethodsService: routingInteractor.buySellServiceProvider.paymentMethods,
            cardListService: routingInteractor.cardServiceProvider.cardList
        )
        let presenter = CardDetailsScreenPresenter(
            interactor: interactor,
            eventRecorder: recordingProvider.analytics,
            messageRecorder: recordingProvider.message
        )
        let viewController = CardDetailsScreenViewController(presenter: presenter)
        return viewController
    }
    
    public func pendingCardStatus(cardId: String) -> UIViewController {
        let interactor = PendingCardStatusInteractor(
            cardId: cardId,
            activationService: routingInteractor.cardServiceProvider.cardActivation,
            paymentMethodTypesService: routingInteractor.buySellServiceProvider.paymentMethodTypes,
            routingInteractor: routingInteractor
        )
        let presenter = PendingCardStatusPresenter(interactor: interactor)
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        return viewController
    }
    
    public func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController {
        let interactor = CardAuthorizationScreenInteractor(routingInteractor: routingInteractor)
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: data,
            eventRecorder: recordingProvider.analytics
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        return viewController
    }
    
    public func billingAddress(for cardData: CardData, navigationControllerAPI: NavigationControllerAPI) -> UIViewController {
        /// TODO: Move `SelectionRouter` to RIBs
        let selectionRouter = SelectionRouter(parent: navigationControllerAPI)
        let interactor = BillingAddressScreenInteractor(
            cardData: cardData,
            service: routingInteractor.cardServiceProvider.cardUpdate,
            userDataRepository: routingInteractor.cardServiceProvider.dataRepository,
            routingInteractor: routingInteractor
        )
        let presenter = BillingAddressScreenPresenter(
            interactor: interactor,
            countrySelectionRouter: selectionRouter,
            eventRecorder: recordingProvider.analytics,
            messageRecorder: recordingProvider.message
        )
        let viewController = BillingAddressScreenViewController(
            presenter: presenter,
            alertViewPresenter: utilityProvider.alert
        )
        return viewController
    }
}
