//
//  ERC20BalanceService.swift
//  ERC20Kit
//
//  Created by Jack on 18/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit
import PlatformKit
import RxSwift

public protocol ERC20BalanceServiceAPI {
    associatedtype Token: ERC20Token

    var balanceForDefaultAccount: Single<ERC20TokenValue<Token>> { get }
    func balance(for address: EthereumAddress) -> Single<ERC20TokenValue<Token>>
}

public class AnyERC20BalanceService<Token: ERC20Token>: ERC20BalanceServiceAPI {
    private let bridge: EthereumWalletBridgeAPI
    private let accountClient: AnyERC20AccountAPIClient<Token>

    init<APIClient: ERC20AccountAPIClientAPI>(
        with bridge: EthereumWalletBridgeAPI,
        accountClient: APIClient) where APIClient.Token == Token {
        self.bridge = bridge
        self.accountClient = AnyERC20AccountAPIClient(accountAPIClient: accountClient)
    }

    public var balanceForDefaultAccount: Single<ERC20TokenValue<Token>> {
        bridge.address
            .flatMap(weak: self) { (self, address) -> Single<ERC20TokenValue<Token>> in
                self.balance(for: address)
            }
    }

    public func balance(for address: EthereumAddress) -> Single<ERC20TokenValue<Token>> {
        accountClient
            .fetchAccountSummary(from: address.publicKey)
            .map { $0.balance }
            .map { Token.cryptoValueFrom(minorValue: $0) ?? Token.zeroValue }
    }
}
