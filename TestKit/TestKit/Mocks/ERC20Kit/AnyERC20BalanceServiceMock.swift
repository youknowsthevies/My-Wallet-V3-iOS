// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift

class ERC20BalanceServiceMock: ERC20BalanceServiceAPI {
    var balanceResponse: Single<CryptoValue>

    init(cryptoCurrency: CryptoCurrency) {
        balanceResponse = .just(.zero(currency: cryptoCurrency))
    }

    func accountBalance(cryptoCurrency: CryptoCurrency) -> Single<CryptoValue> {
        balanceResponse
    }

    func balance(for address: EthereumAddress, cryptoCurrency: CryptoCurrency) -> Single<CryptoValue> {
        balanceResponse
    }
}
