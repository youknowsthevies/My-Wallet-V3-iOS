//
//  ERC20AssetAccountDetailsService.swift
//  ERC20KitTests
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit
import RxSwift

public class ERC20AssetAccountDetailsService<Token: ERC20Token>: AssetAccountDetailsAPI {

    private let bridge: EthereumWalletBridgeAPI
    private let service: AnyERC20BalanceService<Token>

    public convenience init<C: ERC20AccountAPIClientAPI>(with bridge: EthereumWalletBridgeAPI, accountClient: C) where C.Token == Token {
        self.init(
            with: bridge,
            service: AnyERC20BalanceService<Token>(with: bridge, accountClient: accountClient)
        )
    }

    public init(with bridge: EthereumWalletBridgeAPI, service: AnyERC20BalanceService<Token>) {
        self.bridge = bridge
        self.service = service
    }

    // TODO: IOS-3217 Method should use accountID parameter
    public func accountDetails(for accountID: String) -> Single<ERC20AssetAccountDetails> {
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
