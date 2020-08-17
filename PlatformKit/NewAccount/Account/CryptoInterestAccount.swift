//
//  CryptoInterestAccount.swift
//  PlatformKit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import RxSwift
import ToolKit

public class CryptoInterestAccount: CryptoAccount {
    private typealias LocalizedString = LocalizationConstants.Account

    public lazy var id: String = "CryptoInterestAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    public var sendState: Single<SendState> {
        .just(.notSupported)
    }

    public var balance: Single<MoneyValue> {
        balanceAPI.balanceMoney
    }

    public var actions: AvailableActions {
        [.viewActivity]
    }

    public var isFunded: Bool {
        atomicIsFunded.value
    }

    private let balanceAPI: CustodialAccountBalanceFetching
    private let exchangeService: PairExchangeServiceAPI
    private let atomicIsFunded: Atomic<Bool> = .init(false)
    private let disposeBag = DisposeBag()

    public init(asset: CryptoCurrency,
                balanceProviding: BalanceProviding = resolve(),
                exchangeProviding: ExchangeProviding = resolve()) {
        self.label = String(format: LocalizedString.myInterestAccount, asset.name)
        self.asset = asset
        self.exchangeService = exchangeProviding[asset]
        self.balanceAPI = balanceProviding[asset.currency].savings
        balanceAPI.isFunded
            .subscribe(onNext: { [weak self] isFunded in
                self?.atomicIsFunded.mutate { $0 = isFunded }
            })
            .disposed(by: disposeBag)
    }

    public func createSendProcessor(address: ReceiveAddress) -> Single<SendProcessor> {
        unimplemented()
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
}
