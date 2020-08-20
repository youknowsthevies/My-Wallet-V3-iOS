//
//  BitcoinCashCryptoAccount.swift
//  BitcoinKit
//
//  Created by Paulo on 12/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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

    var balance: Single<MoneyValue> {
        balanceService
            .bitcoinCashBalance(for: id)
            .moneyValue
    }

    var actions: AvailableActions {
        [.viewActivity]
    }

    private let exchangeService: PairExchangeServiceAPI
    private let balanceService: BalanceServiceAPI

    init(id: String,
         label: String?,
         isDefault: Bool,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceService: BalanceServiceAPI = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myWallet, CryptoCurrency.bitcoinCash.name)
        self.isDefault = isDefault
        self.exchangeService = exchangeProviding[.bitcoinCash]
        self.balanceService = balanceService
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
