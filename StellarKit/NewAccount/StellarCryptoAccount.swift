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
    let asset: CryptoCurrency = .stellar
    let isDefault: Bool = true

    var balance: Single<MoneyValue> {
        accountDetailsService
            .accountDetails(for: id)
            .map(\.balance.moneyValue)
    }

    var actions: AvailableActions {
        [.viewActivity]
    }

    private let accountDetailsService: AnyAssetAccountDetailsAPI<StellarAssetAccountDetails>
    private let exchangeService: PairExchangeServiceAPI

    init(id: String,
         label: String? = nil,
         accountDetailsService: AnyAssetAccountDetailsAPI<StellarAssetAccountDetails> = resolve(),
         dataProviding: DataProviding = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myWallet, CryptoCurrency.stellar.name)
        self.accountDetailsService = accountDetailsService
        self.exchangeService = dataProviding.exchange[.stellar]
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
