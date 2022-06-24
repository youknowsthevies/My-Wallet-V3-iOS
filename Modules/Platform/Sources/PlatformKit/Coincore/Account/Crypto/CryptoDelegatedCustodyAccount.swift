// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDataKit
import Foundation
import MoneyKit
import RxSwift
import ToolKit

final class CryptoDelegatedCustodyAccount: CryptoAccount, NonCustodialAccount {
    let asset: CryptoCurrency

    let isDefault: Bool = true

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
        balanceRepository
            .balances
            .map { [asset] in
                $0.balance(index: 0, currency: asset) ?? MoneyValue.zero(currency: asset)
            }
            .eraseToAnyPublisher()
    }

    var pendingBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var actionableBalance: AnyPublisher<MoneyValue, Error> {
        .just(.zero(currency: asset))
    }

    var label: String {
        asset.defaultWalletName
    }

    let accountType: AccountType = .nonCustodial

    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let featureFlagsService: FeatureFlagsServiceAPI
    private let priceService: PriceServiceAPI

    init(
        asset: CryptoCurrency,
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        featureFlagsService: FeatureFlagsServiceAPI,
        priceService: PriceServiceAPI
    ) {
        self.asset = asset
        self.balanceRepository = balanceRepository
        self.featureFlagsService = featureFlagsService
        self.priceService = priceService
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .buy:
            return .just(false)
        case .deposit:
            return .just(false)
        case .interestTransfer:
            return .just(false)
        case .interestWithdraw:
            return .just(false)
        case .receive:
            return .just(true)
        case .sell:
            return .just(false)
        case .send:
            return .just(false)
        case .sign:
            return .just(false)
        case .swap:
            return .just(false)
        case .viewActivity:
            return .just(true)
        case .withdraw:
            return .just(false)
        case .linkToDebitCard:
            return .just(false)
        }
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
