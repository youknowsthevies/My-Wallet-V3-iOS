//
//  ExchangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// A provider for exchange rates as per supported crypto.
public protocol ExchangeProviding: class {
    
    /// Returns the exchange service
    subscript(currency: Currency) -> PairExchangeServiceAPI { get }
    
    /// Refreshes all the exchange rates
    func refresh()
}

public final class ExchangeProvider: ExchangeProviding {
    
    public subscript(currency: Currency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }
    
    public subscript(currency: CryptoCurrency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }
    
    public subscript(currency: FiatCurrency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }
    
    // MARK: - Services
    
    private var services: [CurrencyType: PairExchangeServiceAPI] = [:]
    
    // MARK: - Setup
    
    public init(fiats: [FiatCurrency: PairExchangeServiceAPI],
                algorand: PairExchangeServiceAPI,
                ether: PairExchangeServiceAPI,
                pax: PairExchangeServiceAPI,
                stellar: PairExchangeServiceAPI,
                bitcoin: PairExchangeServiceAPI,
                bitcoinCash: PairExchangeServiceAPI,
                tether: PairExchangeServiceAPI) {
        for (currency, service) in fiats {
            services[.fiat(currency)] = service
        }
        services[.crypto(.algorand)] = algorand
        services[.crypto(.ethereum)] = ether
        services[.crypto(.pax)] = pax
        services[.crypto(.stellar)] = stellar
        services[.crypto(.bitcoin)] = bitcoin
        services[.crypto(.bitcoinCash)] = bitcoinCash
        services[.crypto(.tether)] = tether
    }
    
    public func refresh() {
        services.values.forEach { $0.fetchTriggerRelay.accept(()) }
    }
}
