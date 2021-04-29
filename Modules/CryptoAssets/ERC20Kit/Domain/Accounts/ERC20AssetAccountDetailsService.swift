// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift

class ERC20AssetAccountDetailsService<Token: ERC20Token>: AssetAccountDetailsAPI {

    private let bridge: EthereumWalletBridgeAPI
    private let service: ERC20BalanceService<Token>

    init(with bridge: EthereumWalletBridgeAPI = resolve(),
         service: ERC20BalanceService<Token> = resolve()) {
        self.bridge = bridge
        self.service = service
    }

    // TODO: IOS-3217 Method should use accountID parameter
    func accountDetails(for accountID: String) -> Single<ERC20AssetAccountDetails> {
        bridge.address
            .flatMap(weak: self) { (self, address) -> Single<(address: EthereumAddress, balance: CryptoValue)> in
                self.service.balance(for: address).map { (address, $0.value) }
            }
            .map { tuple -> ERC20AssetAccountDetails in
                ERC20AssetAccountDetails(
                    account: ERC20AssetAccountDetails.Account(
                        walletIndex: 0,
                        accountAddress: tuple.address.publicKey,
                        name: "My \(Token.assetType.name) Wallet"
                    ),
                    balance: tuple.balance
                )
            }
    }
}
