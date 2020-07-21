//
//  TradingBalanceServiceAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class TradingBalanceServiceAPIMock: TradingBalanceServiceAPI {
    
    var underlyingCustodialBalance: CustodialAccountBalanceStates!
    var balances: Single<CustodialAccountBalanceStates> {
        .just(underlyingCustodialBalance)
    }
    
    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState> {
        fatalError("TODO")
    }
    
    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        balances
    }
}
