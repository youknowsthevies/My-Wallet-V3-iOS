//
//  OrderQuoteService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol OrderQuoteServiceAPI {
    func fetchQuote(direction: OrderDirection,
                    sourceCurrencyType: CurrencyType,
                    destinationCurrencyType: CurrencyType) -> Single<OrderQuoteResponse>
}

final class OrderQuoteService: OrderQuoteServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let client: CustodialQuoteAPI
    
    // MARK: - Setup
    
    init(client: CustodialQuoteAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - OrderQuoteServiceAPI
    
    public func fetchQuote(direction: OrderDirection,
                           sourceCurrencyType: CurrencyType,
                           destinationCurrencyType: CurrencyType) -> Single<OrderQuoteResponse> {
        let request = OrderQuoteRequest(
            product: .brokerage,
            direction: direction,
            pair: .init(
                sourceCurrencyType: sourceCurrencyType,
                destinationCurrencyType: destinationCurrencyType
            )
        )
        return client.fetchQuoteResponse(with: request)
    }
    
}
