//
//  ActivityProvider.swift
//  PlatformKit
//
//  Created by Alex McGregor on 5/4/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol ActivityProviding: class {
    /// Returns the activity service
    subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI { get }
    subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI { get }
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI { get }
    
    var activityItems: Observable<ActivityItemEventsLoadingState> { get }
    
    func refresh()
}

public final class ActivityProvider: ActivityProviding {
    
    // MARK: - Public Properties
    
    public subscript(currency: CurrencyType) -> ActivityItemEventServiceAPI {
        services[currency]!
    }
    
    public subscript(cryptoCurrency: CryptoCurrency) -> CryptoItemEventServiceAPI {
        services[.crypto(cryptoCurrency)] as! CryptoItemEventServiceAPI
    }
    
    public subscript(fiatCurrency: FiatCurrency) -> FiatItemEventServiceAPI {
        services[.fiat(fiatCurrency)] as! FiatItemEventServiceAPI
    }
    
    // MARK: - Services
    
    private var services: [CurrencyType: ActivityItemEventServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(fiats: [FiatCurrency: ActivityItemEventServiceAPI],
                cryptos: [CryptoCurrency: ActivityItemEventServiceAPI]) {
        for (currency, service) in fiats {
            services[currency.currency] = service
        }
        for (currency, service) in cryptos {
            services[currency.currency] = service
        }
    }
    
    public var activityItems: Observable<ActivityItemEventsLoadingState> {
        activityItemsLoadingStates.map { $0.allActivity }
    }
    
    public func refresh() {
        services.values.forEach { $0.refresh() }
    }
    
    private var activityItemsLoadingStates: Observable<ActivityItemEventsLoadingStates> {
        Observable.combineLatest(
            services[.fiat(.GBP)]!.activityLoadingStateObservable,
            services[.fiat(.EUR)]!.activityLoadingStateObservable,
            services[.crypto(.ethereum)]!.activityLoadingStateObservable,
            services[.crypto(.pax)]!.activityLoadingStateObservable,
            services[.crypto(.stellar)]!.activityLoadingStateObservable,
            services[.crypto(.bitcoin)]!.activityLoadingStateObservable,
            services[.crypto(.bitcoinCash)]!.activityLoadingStateObservable
        )
        .map {
            ActivityItemEventsLoadingStates(
                statePerCurrency: [
                    .fiat(.GBP): $0.0,
                    .fiat(.EUR): $0.1,
                    .crypto(.ethereum): $0.2,
                    .crypto(.pax): $0.3,
                    .crypto(.stellar): $0.4,
                    .crypto(.bitcoin): $0.5,
                    .crypto(.bitcoinCash): $0.6
                ]
            )
        }
        .share()
    }
}
