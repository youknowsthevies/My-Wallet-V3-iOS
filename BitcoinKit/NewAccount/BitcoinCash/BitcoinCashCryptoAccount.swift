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

    var receiveAddress: Single<ReceiveAddress> {
        unimplemented()
    }

    var sendState: Single<SendState> {
        unimplemented()
    }

    var balance: Single<MoneyValue> {
        balanceService
            .bitcoinCashBalance(for: id)
            .moneyValue
            .do(onSuccess: { [weak self] value in
                self?.atomicIsFunded.mutate { $0 = value.isPositive }
            })
    }

    var actions: AvailableActions {
        [.viewActivity]
    }

    var isFunded: Bool {
        atomicIsFunded.value
    }

    private let exchangeService: PairExchangeServiceAPI
    private let balanceService: BalanceServiceAPI
    private let atomicIsFunded = Atomic<Bool>(false)

    init(id: String,
         label: String?,
         isDefault: Bool,
         dataProviding: DataProviding = resolve(),
         balanceService: BalanceServiceAPI = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myAccount, CryptoCurrency.bitcoinCash.name)
        self.isDefault = isDefault
        self.exchangeService = dataProviding.exchange[.bitcoinCash]
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
