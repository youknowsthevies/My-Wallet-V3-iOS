// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

protocol OrderFetchingServiceAPI {
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent>
    func fetchTransactionStatus(with transactionId: String) -> Single<SwapActivityItemEvent.EventStatus>
}

final class OrderFetchingService: OrderFetchingServiceAPI {
    
    // MARK: - Properties
    
    private let client: OrderFetchingClientAPI
    
    // MARK: - Setup
    
    init(client: OrderFetchingClientAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - OrderFetchingClientAPI
    
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent> {
        client.fetchTransaction(with: transactionId)
    }
    
    func fetchTransactionStatus(with transactionId: String) -> Single<SwapActivityItemEvent.EventStatus> {
        client.fetchTransaction(with: transactionId)
            .map(\.status)
    }
}

