//
//  SavingAccountServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SavingAccountServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState>
    func rate(for currency: CryptoCurrency) -> Single<Double>
}
