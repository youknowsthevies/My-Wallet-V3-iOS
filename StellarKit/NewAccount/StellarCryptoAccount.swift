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

    var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    var sendState: Single<SendState> {
        .just(.notSupported)
    }

    var balance: Single<MoneyValue> {
        accountDetailsService
            .accountDetails(for: id)
            .map(\.balance.moneyValue)
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

    private let accountDetailsService: AnyAssetAccountDetailsAPI<StellarAssetAccountDetails>
    private let exchangeService: PairExchangeServiceAPI
    private let atomicIsFunded: Atomic<Bool> = .init(false)

    init(id: String,
         label: String? = nil,
         accountDetailsService: AnyAssetAccountDetailsAPI<StellarAssetAccountDetails> = resolve(),
         dataProviding: DataProviding = resolve()) {
        self.id = id
        self.label = label ?? String(format: LocalizedString.myAccount, CryptoCurrency.stellar.name)
        self.accountDetailsService = accountDetailsService
        self.exchangeService = dataProviding.exchange[.stellar]
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
