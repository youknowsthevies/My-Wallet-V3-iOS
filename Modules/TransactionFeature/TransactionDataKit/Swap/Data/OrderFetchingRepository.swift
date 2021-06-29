// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import PlatformKit
import TransactionKit

final class OrderFetchingRepository: OrderFetchingRepositoryAPI {

    // MARK: - Properties

    private let client: OrderFetchingClientAPI

    // MARK: - Setup

    init(client: OrderFetchingClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderFetchingClientAPI

    func fetchTransaction(
        with transactionId: String
    ) -> Single<SwapActivityItemEvent> {
        client.fetchTransaction(with: transactionId)
            .asObservable()
            .asSingle()
    }

    func fetchTransactionStatus(
        with transactionId: String
    ) -> Single<SwapActivityItemEvent.EventStatus> {
        client.fetchTransaction(with: transactionId)
            .map(\.status)
            .asObservable()
            .asSingle()
    }
}
