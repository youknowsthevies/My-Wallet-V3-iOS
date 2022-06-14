// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public struct DelegatedCustodyBalances {
    public struct Balance {
        let index: Int
        let name: String
        let balance: MoneyValue
    }

    public let balances: [Balance]

    public func balance(index: Int, currency: CryptoCurrency) -> Balance? {
        balances.first(where: { $0.index == index && $0.balance.currency == currency })
    }
}

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
