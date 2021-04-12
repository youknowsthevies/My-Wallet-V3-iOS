//
//  CardAuthrizationScreenInteractor.swift
//  BuySellUIKit
//
//  Created by Daniel on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RIBs

final class CardAuthorizationScreenInteractor: Interactor {
    
    private let routingInteractor: CardAuthorizationRoutingInteractorAPI
    
    init(routingInteractor: CardAuthorizationRoutingInteractorAPI) {
        self.routingInteractor = routingInteractor
    }
    
    public func cardAuthorized(with identifier: String) {
        routingInteractor.cardAuthorized(with: identifier)
    }
}
