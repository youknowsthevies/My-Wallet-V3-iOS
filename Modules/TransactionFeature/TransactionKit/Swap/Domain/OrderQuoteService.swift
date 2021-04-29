// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol OrderQuoteServiceAPI: AnyObject {
    
    // TODO: Domain Model
    var latestQuote: Single<OrderQuoteResponse> { get }

    func fetchQuote(direction: OrderDirection,
                    sourceCurrencyType: CurrencyType,
                    destinationCurrencyType: CurrencyType) -> Single<OrderQuoteResponse>
}

final class OrderQuoteService: OrderQuoteServiceAPI {
    
    // MARK: - Public Properties
    
    var latestQuote: Single<OrderQuoteResponse> {
        unimplemented()
    }
    
    // MARK: - Properties
    
    private let client: CustodialQuoteAPI
    
    // MARK: - Setup
    
    init(client: CustodialQuoteAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - OrderQuoteServiceAPI
    
    func fetchQuote(direction: OrderDirection,
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
