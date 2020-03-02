//
//  CustodialBalanceServiceAPI.swift
//  PlatformKit
//
//  Created by Paulo on 10/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// CustodialBalanceState has the goal of wrapping the behaviour of a optional CustodialBalance inside a non-optional enum.
public enum CustodialBalanceState {
    /// CustodialBalance is absent, this could mean e.g. that a User never funded a Account for the related Currency before
    case absent
    /// CustodialBalance exists
    case present(CustodialBalance)
}

public protocol CustodialBalanceServiceAPI: AnyObject {

    func balance(for crypto: CryptoCurrency) -> Single<CustodialBalanceState>
}
