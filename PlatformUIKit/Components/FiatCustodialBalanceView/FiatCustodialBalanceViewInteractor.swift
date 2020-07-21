//
//  FiatCustodialBalanceViewInteractor.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 6/23/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class FiatCustodialBalanceViewInteractor {
                
    public var currency: Observable<FiatCurrency> {
        guard case CurrencyType.fiat(let currency) = balance.base.currencyType else {
            fatalError("The base currency of `FiatCustodialBalanceViewInteractor` must be a fiat currency type")
        }
        return .just(currency)
    }
    
    let balanceViewInteractor: FiatBalanceViewInteractor
    
    private let balance: MoneyValueBalancePairs
    
    public init(balance: MoneyValueBalancePairs) {
        self.balance = balance
        balanceViewInteractor = FiatBalanceViewInteractor(balance: balance)
    }
}

extension FiatCustodialBalanceViewInteractor: Equatable {
    public static func == (lhs: FiatCustodialBalanceViewInteractor, rhs: FiatCustodialBalanceViewInteractor) -> Bool {
        lhs.balance.base.currencyType == rhs.balance.base.currencyType
    }
}

// MARK: - Array extension to populate balance pairs

extension Array where Element == FiatCustodialBalanceViewInteractor {
    init(balancePairsCalculationStates: MoneyBalancePairsCalculationStates) {
        self = balancePairsCalculationStates.all
            .compactMap { $0.value }
            .filter { CustodialLocallySupportedFiatCurrencies.fiatCurrencies.contains($0.base.fiatValue!.currencyType) }
            .sorted { $0.base.fiatValue!.currencyType.code < $1.base.fiatValue!.currencyType.code }
            .map { FiatCustodialBalanceViewInteractor(balance: $0) }
    }
}
