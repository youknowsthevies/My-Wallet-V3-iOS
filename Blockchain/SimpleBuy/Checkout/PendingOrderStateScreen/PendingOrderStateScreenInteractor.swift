//
//  PendingOrderStateScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class PendingOrderStateScreenInteractor {
        
    // MARK: - Properties
        
    let amount: CryptoValue
    
    private let orderId: String
    private let service: SimpleBuyPendingOrderCompletionServiceAPI

    // MARK: - Setup
    
    init(orderId: String,
         amount: CryptoValue,
         service: SimpleBuyPendingOrderCompletionServiceAPI) {
        self.orderId = orderId
        self.amount = amount
        self.service = service
    }
    
    func startPolling() -> Single<SimpleBuyPolledOrder> {
        service.waitForFinalizedState(of: orderId)
    }
}
