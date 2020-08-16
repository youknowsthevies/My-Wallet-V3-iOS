//
//  EthereumCryptoAccount.swift
//  EthereumKit
//
//  Created by Paulo on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class EthereumCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .ethereum
    let isDefault: Bool = true

    var receiveAddress: Single<ReceiveAddress> {
        unimplemented()
    }

    var sendState: Single<SendState> {
        unimplemented()
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: id)
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
    private let balanceService: EthereumAccountBalanceServiceAPI
    private let exchangeService: PairExchangeServiceAPI
    private let atomicIsFunded: Atomic<Bool> = .init(false)

    init(id: String,
         label: String? = nil,
         dataProviding: DataProviding = resolve(),
         bridge: EthereumWalletBridgeAPI = resolve(),
         balanceService: EthereumAccountBalanceServiceAPI = resolve()) {
        self.id = id
        self.bridge = bridge
        self.exchangeService = dataProviding.exchange[.ethereum]
        self.balanceService = balanceService
        self.label = label ?? String(format: LocalizedString.myAccount, CryptoCurrency.ethereum.name)
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
