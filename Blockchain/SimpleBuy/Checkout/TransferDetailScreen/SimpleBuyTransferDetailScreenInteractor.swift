//
//  SimpleBuyTransferDetailScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class SimpleBuyTransferDetailScreenInteractor {
    
    // MARK: - Types
    
    enum InteractionError: Error {
        case uncancellable
    }
    
    // MARK: - Exposed Properties
    
    let checkoutData: SimpleBuyCheckoutData
    
    // MARK: - Private Properties
    
    private let cancellationService: SimpleBuyOrderCancellationServiceAPI
    
    // MARK: - Setup
    
    init(checkoutData: SimpleBuyCheckoutData,
         cancellationService: SimpleBuyOrderCancellationServiceAPI) {
        self.checkoutData = checkoutData
        self.cancellationService = cancellationService
    }
    
    // MARK: - Exposed Methods
    
    func cancel() -> Observable<Void> {
        switch checkoutData.detailType {
        case .candidate: // Cannot cancel an unsent order
            return .error(InteractionError.uncancellable)
        case .order(let order):
            return cancellationService
                .cancel(order: order.id)
                .andThen(.just(()))
        }
    }
}
