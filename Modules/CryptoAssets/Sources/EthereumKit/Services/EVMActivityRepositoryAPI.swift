// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit

public protocol EVMActivityRepositoryAPI {

    func transactions(
        cryptoCurrency: CryptoCurrency,
        address: String
    ) -> AnyPublisher<[EVMHistoricalTransaction], Error>
}

extension EVMActivityRepositoryAPI {

    public func transactions(
        cryptoCurrency: CryptoCurrency,
        address: EthereumAddress
    ) -> AnyPublisher<[EVMHistoricalTransaction], Error> {
        transactions(
            cryptoCurrency: cryptoCurrency,
            address: address.publicKey
        )
    }
}
