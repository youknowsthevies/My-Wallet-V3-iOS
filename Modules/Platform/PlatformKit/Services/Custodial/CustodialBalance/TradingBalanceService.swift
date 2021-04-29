// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol TradingBalanceServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }
    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState>
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
}

class TradingBalanceService: TradingBalanceServiceAPI {

    // MARK: - Properties
    
    var balances: Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.valueSingle
    }
    
    // MARK: - Private Properties
    
    private let client: TradingBalanceClientAPI
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

    init(client: TradingBalanceClientAPI = resolve()) {
        self.client = client
        cachedValue = CachedValue(configuration: .onSubscription())        
    }

    // MARK: - Methods

    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState> {
        client
            .balance(for: currencyType)
            .map { response -> CustodialAccountBalanceState in
                guard let balance = response?[currencyType] else {
                    return .absent
                }
                let accountBalance = CustodialAccountBalance(currency: currencyType, response: balance)
                return .present(accountBalance)
            }
            .catchErrorJustReturn(.absent)
    }
    
    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        _ = setup
        return cachedValue.fetchValue
    }
}
