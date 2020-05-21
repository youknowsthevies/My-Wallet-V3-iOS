//
//  AssetBalanceChangeProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 31/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

/// A provider for balance change
public protocol AssetBalanceChangeProviding: class {
    
    /// A balance fetcher
    var balance: AssetBalanceFetching { get }
    
    /// A prices provider
    var prices: HistoricalFiatPriceServiceAPI { get }
    
    /// The measured change over a time period
    var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> { get }
}

public final class AssetBalanceChangeProvider: AssetBalanceChangeProviding {
    
    // MARK: - AssetBalanceChangeProviding
    
    public let balance: AssetBalanceFetching
    public let prices: HistoricalFiatPriceServiceAPI
    
    public var calculationState: Observable<AssetFiatCryptoBalanceCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let calculationStateRelay = BehaviorRelay<AssetFiatCryptoBalanceCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balance: AssetBalanceFetching,
                prices: HistoricalFiatPriceServiceAPI) {
        self.balance = balance
        self.prices = prices
        Observable
            .combineLatest(balance.calculationState, prices.calculationState)
            .map { (balance, prices) in
                guard let walletBalance = balance.value?[.nonCustodial] else { return .calculating }
                guard let tradingBalance = balance.value?[.custodial(.trading)] else { return .calculating }
                guard let savingsBalance = balance.value?[.custodial(.savings)] else { return .calculating }
                guard let historicalPriceValue = prices.value else { return .calculating }
                
                let delta = historicalPriceValue.historicalPrices.delta
                
                let previousWalletBalance = try walletBalance.value(before: delta)
                let previousTradingBalance = try tradingBalance.value(before: delta)
                let previousSavingsBalance = try savingsBalance.value(before: delta)

                return .value(.init(
                        wallet: try walletBalance - previousWalletBalance,
                        trading: try tradingBalance - previousTradingBalance,
                        savings: try savingsBalance - previousSavingsBalance
                    )
                )
            }
            .catchErrorJustReturn(.calculating) // TODO: Error handling
            .bind(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
