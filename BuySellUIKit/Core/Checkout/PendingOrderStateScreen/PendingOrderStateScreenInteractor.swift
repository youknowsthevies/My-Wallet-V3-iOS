//
//  PendingOrderStateScreenInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 23/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

final class PendingOrderStateScreenInteractor: Interactor {
        
    // MARK: - Properties
        
    var amount: MoneyValue {
        isBuy ? orderDetails.outputValue : orderDetails.inputValue
    }
    
    var isBuy: Bool {
        orderDetails.isBuy
    }
    
    var inputCurrencyType: CurrencyType {
        orderDetails.inputValue.currencyType
    }
    
    var outputCurrencyType: CurrencyType {
        orderDetails.outputValue.currencyType
    }
    
    private let orderDetails: OrderDetails
    private let service: PendingOrderCompletionServiceAPI

    // MARK: - Setup
    
    init(orderDetails: OrderDetails,
         service: PendingOrderCompletionServiceAPI) {
        self.orderDetails = orderDetails
        self.service = service
    }
    
    func startPolling() -> Single<PolledOrder> {
        service.waitForFinalizedState(of: orderDetails.identifier)
    }
}
