//
//  SimpleBuyFlowAvailabilityService.swift
//  Blockchain
//
//  Created by Paulo on 10/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public final class SimpleBuyFlowAvailabilityService: SimpleBuyFlowAvailabilityServiceAPI {

    public init() { }

    /// Indicates that the current Fiat Currency is supported by Simple Buy locally.
    public func isFiatCurrencySupportedLocal(currency: FiatCurrency) -> Single<Bool> {
        /// Frontend has implemented logic for the given fiat currency
        Single.just(SimpleBuyLocallySupportedCurrencies.fiatCurrencies.contains(currency))
    }
}
