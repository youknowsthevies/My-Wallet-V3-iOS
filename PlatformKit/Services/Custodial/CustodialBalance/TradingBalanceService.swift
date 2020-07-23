//
//  TradingBalanceService.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public protocol TradingBalanceServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }
    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState>
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
}

public class TradingBalanceService: TradingBalanceServiceAPI {

    // MARK: - Public Properties
    
    public var balances: Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.valueSingle
    }
    
    // MARK: - Private Properties
    
    private let client: CustodialClientAPI
    private let cachedValue: CachedValue<CustodialAccountBalanceStates>
    
    private let lock = NSLock()
    
    private lazy var setup: Void = {
        lock.lock()
        defer { lock.unlock() }
        cachedValue.setFetch(weak: self) { (self) in
            self.client.balance
                .map { response in
                    guard let response = response else {
                        return .absent
                    }
                    return CustodialAccountBalanceStates(response: response)
                }
        }
    }()
    
    // MARK: - Setup
    
    public convenience init() {
        self.init(client: resolve())
    }

    init(client: CustodialClientAPI) {
        self.client = client
        cachedValue = CachedValue(configuration: .onSubscription())        
    }

    // MARK: - Public Methods

    public func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState> {
        client
            .balance(for: currencyType.code)
            .map { response -> CustodialAccountBalanceState in
                guard let response = response else {
                    return .absent
                }
                guard let balance = response[currencyType.code] else {
                    return .absent
                }
                let accountBalance = CustodialAccountBalance(currency: currencyType, response: balance)
                return .present(accountBalance)
            }
            .catchErrorJustReturn(.absent)
    }
    
    public func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.fetchValue
    }
}
