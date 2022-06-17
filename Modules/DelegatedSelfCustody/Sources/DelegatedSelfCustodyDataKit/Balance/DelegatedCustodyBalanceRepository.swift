// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol DelegatedCustodyBalanceRepositoryAPI {
    var balances: AnyPublisher<DelegatedCustodyBalances, Error> { get }
}

final class DelegatedCustodyBalanceRepository: DelegatedCustodyBalanceRepositoryAPI {

    var balances: AnyPublisher<DelegatedCustodyBalances, Error> {
        .just(DelegatedCustodyBalances(balances: []))
    }

    private let client: AccountDataClientAPI

    init(client: AccountDataClientAPI) {
        self.client = client
    }
}
