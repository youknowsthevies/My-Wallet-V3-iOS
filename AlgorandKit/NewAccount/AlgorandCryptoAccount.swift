//
//  AlgorandCryptoAccount.swift
//  AlgorandKit
//
//  Created by Paulo on 14/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

class AlgorandCryptoAccount: CryptoNonCustodialAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    let id: String
    let label: String
    let asset: CryptoCurrency = .algorand
    let isDefault: Bool = true

    var receiveAddress: Single<ReceiveAddress> {
        unimplemented()
    }

    var sendState: Single<SendState> {
        unimplemented()
    }

    var balance: Single<MoneyValue> {
        unimplemented()
    }

    var actions: AvailableActions {
        []
    }

    var isFunded: Bool {
        atomicIsFunded.value
    }

    private let exchangeService: PairExchangeServiceAPI
    private let atomicIsFunded: Atomic<Bool> = .init(false)
    
    init(id: String,
         label: String?,
         dataProviding: DataProviding = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myAccount, CryptoCurrency.algorand.name)
        self.exchangeService = dataProviding.exchange[.algorand]
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
