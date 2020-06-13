//
//  TransferDetailScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 06/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import BuySellKit

enum TermsUrlLink {
    static let gbp = "https://exchange.blockchain.com/legal#modulr"
}

final class TransferDetailScreenInteractor {
    
    // MARK: - Types
        
    enum InteractionError: Error {
        case uncancellable
    }
    
    // MARK: - Exposed Properties
    
    let checkoutData: CheckoutData
    
    // MARK: - Private Properties
    
    private let cancellationService: SimpleBuyOrderCancellationServiceAPI
    
    // MARK: - Setup
    
    init(checkoutData: CheckoutData,
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
                .cancel(order: order.identifier)
                .andThen(.just(()))
        }
    }
}
