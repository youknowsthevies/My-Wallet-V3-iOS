//
//  CryptoInterestAccount.swift
//  PlatformKit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit
import Localization

public class CryptoInterestAccount: CryptoAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    public let asset: CryptoCurrency

    public var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    public let isDefault: Bool = false

    public var sendState: Single<SendState> {
        .just(.notSupported)
    }

    public func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor> {
        unimplemented()
    }

    public lazy var id: String = "CryptoInterestAccount" + asset.code

    public let label: String

    public var balance: Single<MoneyValue> {
        let asset = self.asset
        return balanceAPI
            .balance(for: asset)
            .do(onSuccess: { [weak self] (state: CustodialAccountBalanceState) in
                let isFunded: Bool = state != .absent
                self?.atomicIsFunded.mutate { $0 = isFunded }
            })
            .map { $0.balance?.available ?? MoneyValue.zero(asset) }
    }

    public var actions: AvailableActions = []

    private let atomicIsFunded: Atomic<Bool> = .init(false)
    public var isFunded: Bool {
        atomicIsFunded.value
    }

    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        Single
            .zip(
                exchangeService.fiatPrice.take(1).asSingle(),
                balance
            ) { (exchangeRate: $0, balance: $1) }
            .map { try MoneyValuePair(base: $0.balance, exchangeRate: $0.exchangeRate.moneyValue) }
            .map(\.quote)
    }

    private let balanceAPI: SavingAccountServiceAPI
    private let exchangeService: PairExchangeServiceAPI

    public init(asset: CryptoCurrency,
                dataProviding: DataProviding = resolve(),
                balanceAPI: SavingAccountServiceAPI = resolve()) {
        self.label = String(format: LocalizedString.myInterestAccount, asset.name)
        self.asset = asset
        self.exchangeService = dataProviding.exchange[asset]
        self.balanceAPI = balanceAPI
    }
}
