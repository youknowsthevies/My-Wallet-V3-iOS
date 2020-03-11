//
//  SimpleBuyFlowAvailabilityService.swift
//  Blockchain
//
//  Created by Paulo on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyFlowAvailabilityService: SimpleBuyFlowAvailabilityServiceAPI {

    /// Indicates that Simple Buy Flow is available for the current user because:
    /// a) They never traded with Coinify before.
    /// b) They are using a supported currency by the backend.
    /// c) They are using a supported currency by the frontend.
    public var isSimpleBuyFlowAvailable: Observable<Bool> {
        Observable
            .combineLatest(
                isFiatCurrencySupported,
                userHasCoinify.asObservable()
            )
            .map { isFiatCurrencySupported, userHasCoinify in
                isFiatCurrencySupported && !userHasCoinify
            }
            .catchErrorJustReturn(false)
    }

    /// Indicates that the user traded with Coinify before
    private var userHasCoinify: Single<Bool> {
        Single
            .deferred { [weak self] () -> Single<Bool> in
                let hasCoinifyAccount = self?.coinifyAccountRepository.hasCoinifyAccount() ?? true
                return .just(hasCoinifyAccount)
            }
            .subscribeOn(MainScheduler.instance)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }

    /// Indicates that the current Fiat Currency is supported by Simple Buy remotely.
    private func isFiatCurrencySupportedRemote(currency: FiatCurrency) -> Single<Bool> {
        supportedPairsService
            .fetchPairs(for: .only(fiatCurrency: currency))
            /// Backend has at least one pair for the given fiat currency
            .map { !$0.pairs.isEmpty  }
    }

    /// Indicates that the current Fiat Currency is supported by Simple Buy locally.
    private func isFiatCurrencySupportedLocal(currency: FiatCurrency) -> Single<Bool> {
        /// Frontend has implemented logic for the given fiat currency
        Single.just(SimpleBuyLocallySupportedCurrencies.fiatCurrencies.contains(currency))
    }

    /// Indicates that the current Fiat Currency is supported by Simple Buy both locally and remotely.
    private var isFiatCurrencySupported: Observable<Bool> {
        fiatCurrencyService
            .fiatCurrencyObservable
            .flatMap(weak: self) { (self, currency) in
                Single
                    .zip(
                        self.isFiatCurrencySupportedRemote(currency: currency),
                        self.isFiatCurrencySupportedLocal(currency: currency)
                    )
                    .map { $0 && $1 }
                    .asObservable()
            }
    }

    private let coinifyAccountRepository: CoinifyAccountRepositoryAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let supportedPairsService: SimpleBuySupportedPairsServiceAPI

    public init(coinifyAccountRepository: CoinifyAccountRepositoryAPI,
                fiatCurrencyService: FiatCurrencySettingsServiceAPI,
                supportedPairsService: SimpleBuySupportedPairsServiceAPI) {
        self.coinifyAccountRepository = coinifyAccountRepository
        self.fiatCurrencyService = fiatCurrencyService
        self.supportedPairsService = supportedPairsService
    }
}
