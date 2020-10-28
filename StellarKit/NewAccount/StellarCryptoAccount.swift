//
//  StellarCryptoAccount.swift
//  StellarKit
//
//  Created by Paulo on 10/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class StellarCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    var balance: Single<MoneyValue> {
        balanceFetching
            .balanceMoney
    }
    
    var pendingBalance: Single<MoneyValue> {
        balanceFetching
            .pendingBalanceMoney
    }

    var actions: AvailableActions {
        [.viewActivity, .receive, .send, .swap]
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(StellarReceiveAddress(address: id, label: label))
    }

    private let balanceFetching: SingleAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String? = nil,
         balanceProviding: BalanceProviding = resolve(),
         exchangeProviding: ExchangeProviding = resolve()) {
        let asset = CryptoCurrency.stellar
        self.asset = asset
        self.id = id
        self.label = label ?? asset.defaultWalletName
        self.balanceFetching = balanceProviding[asset.currency].wallet
        self.exchangeService = exchangeProviding[asset]
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
