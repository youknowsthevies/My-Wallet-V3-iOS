//
//  TransactionLimitService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol TransactionLimitsServiceAPI {
    var transactionLimits: Single<TransactionLimits> { get }
    func fetchTransactionLimits() -> Single<TransactionLimits>
}

final class TransactionLimitsService: TransactionLimitsServiceAPI {
    
    // MARK: - Public Properties
    
    var transactionLimits: Single<TransactionLimits> {
        transactionLimitsCachedValue.valueSingle
    }
    
    // MARK: - Properties
    
    private let transactionLimitsCachedValue = CachedValue<TransactionLimits>(
        configuration: .init(
            refreshType: .onSubscription,
            flushNotificationName: .logout
        )
    )
    
    private let client: OrderTransactionLimitsClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    
    // MARK: - Setup
    
    init(client: OrderTransactionLimitsClientAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve()) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService
        
        transactionLimitsCachedValue.setFetch(weak: self) { (self) in
            self.fiatCurrencyService
                .fiatCurrency
                .flatMap(weak: self) { (self, fiatCurrency) -> Single<TransactionLimits> in
                    self.client
                        .fetchTransactionLimits(
                            for: fiatCurrency,
                            networkFee: fiatCurrency,
                            minorValues: true
                        )
                }
        }
    }
    
    // MARK: - TransactionLimitServiceAPI
    
    func fetchTransactionLimits() -> Single<TransactionLimits> {
        transactionLimitsCachedValue.fetchValue
    }
}
