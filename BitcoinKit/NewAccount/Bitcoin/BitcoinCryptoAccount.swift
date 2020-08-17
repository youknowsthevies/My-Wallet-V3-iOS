//
//  BitcoinCryptoAccount.swift
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

class BitcoinCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .bitcoin
    let isDefault: Bool

    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var sendState: Single<SendState> {
        .just(.notSupported)
    }

    var balance: Single<MoneyValue> {
        balanceService
            .bitcoinBalance(for: id)
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
    private let atomicIsFunded: Atomic<Bool> = .init(false)

    init(id: String,
         label: String?,
         isDefault: Bool,
         exchangeProviding: ExchangeProviding = resolve(),
         balanceService: BalanceServiceAPI = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myAccount, CryptoCurrency.bitcoin.name)
        self.isDefault = isDefault
        self.exchangeService = exchangeProviding[.bitcoin]
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
