// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxSwift
import TransactionKit

final class AvailablePairsRepository: AvailablePairsRepositoryAPI {

    // MARK: - AvailablePairsRepositoryAPI

    var availableOrderPairs: Single<[OrderPair]> {
        client.availableOrderPairs
            .map(\.pairs)
            .map { $0.compactMap(OrderPair.init(rawValue:)) }
            .asObservable()
            .asSingle()
    }

    // MARK: - Private properties

    private let client: AvailablePairsClientAPI

    // MARK: - Setup

    init(client: AvailablePairsClientAPI = resolve()) {
        self.client = client
    }
}
