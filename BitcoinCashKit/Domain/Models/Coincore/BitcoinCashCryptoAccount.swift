//
//  BitcoinCashCryptoAccount.swift
//  BitcoinCashKit
//
//  Created by Paulo on 12/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinChainKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class BitcoinCashCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .bitcoinCash
    let isDefault: Bool
    
    var pendingBalance: Single<MoneyValue> {
        Single.just(MoneyValue.zero(currency: .bitcoinCash))
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: id)
            .moneyValue
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        let account = bridge
            .wallets
            .map(weak: self) { (self, wallets) in 
                wallets.filter { $0.label == self.label }
            }
            .map { accounts -> BitcoinCashWalletAccount in
                guard let account = accounts.first else {
                    throw PlatformKitError.illegalStateException(message: "Expected a BitcoinCashWalletAccount")
                }
                return account
            }
        
        return Single.zip(bridge.receiveAddress(forXPub: id), account)
            .map(weak: self) { (self, values) -> ReceiveAddress in
                let (address, account) = values
                return BitcoinChainReceiveAddress<BitcoinCashToken>(
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted,
                    index: Int32(account.index)
                )
            }
    }

    private let exchangeService: PairExchangeServiceAPI
    private let balanceService: BalanceServiceAPI
    private let bridge: BitcoinCashWalletBridgeAPI

    init(id: String,
         label: String?,
         isDefault: Bool,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainCoin.bitcoinCash),
         bridge: BitcoinCashWalletBridgeAPI = resolve()) {
        self.id = id
        self.label = label ?? CryptoCurrency.bitcoinCash.defaultWalletName
        self.isDefault = isDefault
        self.exchangeService = exchangeProviding[.bitcoinCash]
        self.balanceService = balanceService
        self.bridge = bridge
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
