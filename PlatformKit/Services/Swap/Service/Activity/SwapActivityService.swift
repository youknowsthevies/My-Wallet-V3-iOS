//
//  SwapActivityService.swift
//  PlatformKit
//
//  Created by Alex McGregor on 4/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
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

final class SwapActivityService: SwapActivityServiceAPI {
    
    private let client: SwapClientAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    
    init(client: SwapClientAPI = resolve(),
         fiatCurrencyProvider: CompleteSettingsServiceAPI = resolve()) {
        self.fiatCurrencyProvider = fiatCurrencyProvider
        self.client = client
    }
    
    func fetchActivity(from date: Date) -> Single<[SwapActivityItemEvent]> {
        fiatCurrencyProvider.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<[SwapActivityItemEvent]> in
                self.client.fetchActivity(
                    from: date,
                    fiatCurrency: fiatCurrency.code
                )
            }
    }
    
    func fetchActivity(from date: Date, cryptoCurrency: CryptoCurrency) -> Single<[SwapActivityItemEvent]> {
        fiatCurrencyProvider.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<[SwapActivityItemEvent]> in
                self.client.fetchActivity(
                    from: date,
                    fiatCurrency: fiatCurrency.code,
                    cryptoCurrency: cryptoCurrency,
                    limit: self.pageSize
                )
            }
    }
}
