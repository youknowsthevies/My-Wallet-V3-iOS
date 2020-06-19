//
//  TransferCancellationInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import BuySellKit

final class TransferCancellationInteractor {
    
    // MARK: - Types
    
    enum InteractionError: Error {
        case uncancellable
    }
    
    // MARK: - Exposed Properties
    
    let checkoutData: CheckoutData
    
    // MARK: - Private Properties
    
    private let cancellationService: OrderCancellationServiceAPI
    
    // MARK: - Setup
    
    init(checkoutData: CheckoutData,
         cancellationService: OrderCancellationServiceAPI) {
        self.checkoutData = checkoutData
        self.cancellationService = cancellationService
    }
    
    // MARK: - Exposed Methods
    
    func cancel() -> Observable<Void> {
        cancellationService
            .cancel(order: checkoutData.order.identifier)
            .andThen(.just(()))
    }
}
