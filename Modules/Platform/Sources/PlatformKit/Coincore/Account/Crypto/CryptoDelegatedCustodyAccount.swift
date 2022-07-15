// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DelegatedSelfCustodyDomain
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

    var receiveAddress: AnyPublisher<ReceiveAddress, Error> {
        addressesRepository
            .addresses(for: asset)
            .map { [publicKey] addresses in
                addresses
                    .first(where: { address in
                        address.publicKey == publicKey && address.isDefault
                    })
            }
            .onNil(ReceiveAddressError.notSupported)
            .flatMap { [addressFactory] match in
                addressFactory
                    .makeExternalAssetAddress(
                        address: match.address,
                        label: match.address,
                        onTxCompleted: { _ in .empty() }
                    )
                    .publisher
                    .eraseError()
            }
            .map { $0 as ReceiveAddress }
            .eraseToAnyPublisher()
    }

    var requireSecondPassword: Single<Bool> {
        .never()
    }

    var balance: AnyPublisher<MoneyValue, Error> {
        balanceRepository
            .balances
            .map { [asset] balances in
                balances.balance(index: 0, currency: asset) ?? MoneyValue.zero(currency: asset)
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

    private let addressesRepository: DelegatedCustodyAddressesRepositoryAPI
    private let addressFactory: ExternalAssetAddressFactory
    private let balanceRepository: DelegatedCustodyBalanceRepositoryAPI
    private let priceService: PriceServiceAPI
    private let publicKey: String

    init(
        addressesRepository: DelegatedCustodyAddressesRepositoryAPI,
        addressFactory: ExternalAssetAddressFactory,
        asset: CryptoCurrency,
        balanceRepository: DelegatedCustodyBalanceRepositoryAPI,
        priceService: PriceServiceAPI,
        publicKey: String
    ) {
        self.addressesRepository = addressesRepository
        self.addressFactory = addressFactory
        self.asset = asset
        self.balanceRepository = balanceRepository
        self.priceService = priceService
        self.publicKey = publicKey
    }

    func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        switch action {
        case .buy,
             .deposit,
             .interestTransfer,
             .interestWithdraw,
             .sell,
             .send,
             .sign,
             .swap,
             .withdraw,
             .linkToDebitCard:
            return .just(false)
        case .receive, .viewActivity:
            return .just(true)
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
