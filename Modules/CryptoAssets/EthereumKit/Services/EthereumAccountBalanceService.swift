// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift

protocol EthereumAccountBalanceServiceAPI {
    
    func balance(for address: String) -> Single<CryptoValue>
}

final class EthereumAccountBalanceService: EthereumAccountBalanceServiceAPI {

    private let client: APIClientAPI

    init(client: APIClientAPI = resolve()) {
        self.client = client
    }

    func balance(for address: String) -> Single<CryptoValue> {
        client
            .balanceDetails(from: address)
            .map(\.cryptoValue)
    }
}
