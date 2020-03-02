//
//  CustodialBalanceServiceAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class CustodialBalanceServiceAPIMock: CustodialBalanceServiceAPI {
    var underlyingCustodialBalance: CustodialBalanceState = .absent
    func balance(for crypto: CryptoCurrency) -> Single<CustodialBalanceState> {
        return .just(underlyingCustodialBalance)
    }
}
