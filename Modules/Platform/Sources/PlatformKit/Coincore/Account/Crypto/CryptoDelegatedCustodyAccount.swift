// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MoneyKit
import RxSwift
import ToolKit

final class CryptoDelegatedCustodyAccount: CryptoAccount, NonCustodialAccount {
    var asset: CryptoCurrency

    var isDefault: Bool = true

    lazy var identifier: AnyHashable = "CryptoDelegatedCustodyAccount.\(asset.code)"

    var activity: Single<[ActivityItemEvent]> {
        .never()
    }

    var receiveAddress: Single<ReceiveAddress> {
        .never()
    }

    var requireSecondPassword: Single<Bool> {
        .never()
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        .empty()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .empty()
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .empty()
    }

    var label: String

    var accountType: AccountType = .nonCustodial

    private let featureFlagsService: FeatureFlagsServiceAPI
    private let priceService: PriceServiceAPI

    init(
        asset: CryptoCurrency,
        featureFlagsService: FeatureFlagsServiceAPI,
        priceService: PriceServiceAPI
    ) {
        self.asset = asset
        label = asset.defaultWalletName
        self.featureFlagsService = featureFlagsService
        self.priceService = priceService
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        .empty()
    }

    func balancePair(
        fiatCurrency: FiatCurrency,
        at time: PriceTime
    ) -> AnyPublisher<MoneyValuePair, Error> {
        balancePair(
            priceService: priceService,
            fiatCurrency: fiatCurrency,
            at: time
        )
    }

    func invalidateAccountBalance() {}
}
