// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift

public protocol ERC20BalanceServiceAPI {
    func accountBalance(cryptoCurrency: CryptoCurrency) -> Single<CryptoValue>
    func balance(for address: EthereumAddress, cryptoCurrency: CryptoCurrency) -> Single<CryptoValue>
}

class ERC20BalanceService: ERC20BalanceServiceAPI {
    private let bridge: EthereumWalletBridgeAPI
    private let accountClient: ERC20AccountAPIClientAPI

    init(
        with bridge: EthereumWalletBridgeAPI = resolve(),
        accountClient: ERC20AccountAPIClientAPI = resolve()
    ) {
        self.bridge = bridge
        self.accountClient = accountClient
    }

    func accountBalance(cryptoCurrency: CryptoCurrency) -> Single<CryptoValue> {
        bridge.address
            .flatMap(weak: self) { (self, address) -> Single<CryptoValue> in
                self.balance(for: address, cryptoCurrency: cryptoCurrency)
            }
    }

    func balance(for address: EthereumAddress, cryptoCurrency: CryptoCurrency) -> Single<CryptoValue> {
        guard let contractAddress = cryptoCurrency.contractAddress else {
            fatalError("Using ERC20BalanceService with \(cryptoCurrency.code)")
        }
        return accountClient
            .fetchAccountSummary(from: address.publicKey, contractAddress: contractAddress)
            .map(\.balance)
            .map { stringValue -> CryptoValue in
                CryptoValue.create(minor: stringValue, currency: cryptoCurrency) ?? CryptoValue.zero(currency: cryptoCurrency)
            }
    }
}
