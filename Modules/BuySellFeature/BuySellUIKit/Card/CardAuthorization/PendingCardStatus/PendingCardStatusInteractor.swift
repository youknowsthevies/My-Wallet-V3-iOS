//
//  PendingCardStatusInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 21/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

final class PendingCardStatusInteractor: Interactor {
    
    // MARK: - Types
    
    enum State {
        case active(CardData)
        case inactive
        case timeout
    }
    
    // MARK: - Properties
        
    private let cardId: String
    private let activationService: CardActivationServiceAPI
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let routingInteractor: CardRouterInteractor

    // MARK: - Setup
    
    init(cardId: String,
         activationService: CardActivationServiceAPI = resolve(),
         paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         routingInteractor: CardRouterInteractor) {
        self.cardId = cardId
        self.routingInteractor = routingInteractor
        self.activationService = activationService
        self.paymentMethodTypesService = paymentMethodTypesService
    }
    
    func startPolling() -> Single<State> {
        activationService
            .waitForActivation(of: cardId)
            .flatMap(weak: self) { (self, result) -> Single<State> in
                switch result {
                case .final(let state):
                    switch state {
                    case .active(let data):
                        return self.paymentMethodTypesService
                            .fetchCards(andPrefer: data.identifier)
                            .andThen(Single.just(.active(data)))
                    case .pending, .inactive:
                        return .just(.inactive)
                    }
                case .cancel:
                    return .just(.inactive)
                case .timeout:
                    return .just(.timeout)
                }
            }
    }
    
    /// End the polling in confirmation state
    /// - Parameter cardData: The data of the card
    func endWithConfirmation(with cardData: CardData) {
        routingInteractor.end(with: cardData)
    }
    
    /// End the polling without confirmation 
    func endWithoutConfirmation() {
        routingInteractor.dismiss()
    }
}
