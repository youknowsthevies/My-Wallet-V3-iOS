//
//  SwapActivityService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SwapActivityServiceAPI: class {
    var pageSize: Int { get }
    func fetchActivity(from date: Date) -> Single<[SwapActivityItemEvent]>
    func fetchActivity(from date: Date, cryptoCurrency: CryptoCurrency) -> Single<[SwapActivityItemEvent]>
}

extension SwapActivityServiceAPI {
    public var pageSize: Int {
        50
    }
}

public final class SwapActivityService: SwapActivityServiceAPI {
    
    private let client: SwapClientAPI
    private let authenticationService: NabuAuthenticationServiceAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    
    public init(client: SwapClientAPI = SwapClient(),
                authenticationService: NabuAuthenticationServiceAPI,
                fiatCurrencyProvider: FiatCurrencySettingsServiceAPI) {
        self.fiatCurrencyProvider = fiatCurrencyProvider
        self.client = client
        self.authenticationService = authenticationService
    }
    
    public func fetchActivity(from date: Date) -> Single<[SwapActivityItemEvent]> {
        Single.zip(
                authenticationService.tokenString,
                fiatCurrencyProvider.fiatCurrency
            )
            .flatMap(weak: self) { (self, values) -> Single<[SwapActivityItemEvent]> in
                let sessionToken = values.0
                let fiatCurrency = values.1.code
                return self.client.fetchActivity(
                    from: date,
                    fiatCurrency: fiatCurrency,
                    token: sessionToken
                )
            }
    }
    
    public func fetchActivity(from date: Date, cryptoCurrency: CryptoCurrency) -> Single<[SwapActivityItemEvent]> {
        Single.zip(
            authenticationService.tokenString,
            fiatCurrencyProvider.fiatCurrency
            )
            .flatMap(weak: self) { (self, values) -> Single<[SwapActivityItemEvent]> in
                let sessionToken = values.0
                let fiatCurrency = values.1.code
                return self.client.fetchActivity(
                    from: date,
                    fiatCurrency: fiatCurrency,
                    cryptoCurrency: cryptoCurrency,
                    limit: self.pageSize,
                    token: sessionToken
                )
            }
    }
}
