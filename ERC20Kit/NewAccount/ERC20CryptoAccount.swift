//
//  ERC20CryptoAccount.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount<Token: ERC20Token>: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account
    
    let id: String
    let label: String
    let asset: CryptoCurrency = Token.assetType
    let isDefault: Bool = true
    
    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }
    
    var sendState: Single<SendState> {
        .just(.notSupported)
    }
    
    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: EthereumAddress(stringLiteral: id))
            .map(\.moneyValue)
            .do(onSuccess: { [weak self] (value: MoneyValue) in
                self?.atomicIsFunded.mutate { $0 = value.isPositive }
            })
    }
    
    var actions: AvailableActions {
        [.viewActivity]
    }
    
    var isFunded: Bool {
        atomicIsFunded.value
    }
    
    private let bridge: EthereumWalletBridgeAPI
    private let balanceService: ERC20BalanceService<Token>
    private let exchangeService: PairExchangeServiceAPI
    private let atomicIsFunded: Atomic<Bool> = .init(false)
    
    init(id: String,
         exchangeProviding: ExchangeProviding = resolve(),
         bridge: EthereumWalletBridgeAPI = resolve(),
         balanceService: ERC20BalanceService<Token> = resolve()) {
        self.id = id
        self.label = String(format: LocalizedString.myAccount, Token.name)
        self.bridge = bridge
        self.exchangeService = exchangeProviding[Token.assetType]
        self.balanceService = balanceService
    }
    
    func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor> {
        unimplemented()
    }
    
    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                exchangeService.fiatPrice.take(1).asSingle(),
                balance
            ) { (exchangeRate: $0, balance: $1) }
            .map { try MoneyValuePair(base: $0.balance, exchangeRate: $0.exchangeRate.moneyValue) }
            .map(\.quote)
    }
}
