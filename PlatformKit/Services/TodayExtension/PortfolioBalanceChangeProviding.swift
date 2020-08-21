//
//  PortfolioBalanceChangeProviding.swift
//  PlatformKit
//
//  Created by Alex McGregor on 7/2/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public protocol PortfolioBalanceChangeProviding {
    var changeObservable: Observable<PortfolioBalanceChange> { get }
}

public final class PortfolioBalanceChangeProvider: PortfolioBalanceChangeProviding {

    // MARK: - Exposed Properties
    
    public var changeObservable: Observable<PortfolioBalanceChange> {
        _ = setup
        return changeRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        Observable.combineLatest(balanceProvider.fiatBalance, balanceChangeProvider.change)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { (balance, change) -> PortfolioBalanceChange in
                guard let currentBalance = balance.value else { return .zero }
                guard change.containsValue else { return .zero }
                guard let changeValue = change.totalFiat.value else { return .zero }
                
                let percentage: Decimal // in range [0...1]
                if currentBalance.isZero {
                    percentage = 0
                } else {
                    let previousBalance = try currentBalance - changeValue
                    
                    /// `zero` shouldn't be possible but is handled in any case
                    /// in a wa that would not throw
                    if previousBalance.isZero {
                        percentage = 0
                    } else {
                        let precentageFiat = try changeValue / previousBalance
                        percentage = precentageFiat.displayMajorValue
                    }
                }
                return .init(
                    balance: currentBalance.displayMajorValue,
                    changePercentage: percentage.doubleValue,
                    change: changeValue.displayMajorValue
                )
            }
            .catchErrorJustReturn(.zero)
            .bindAndCatch(to: changeRelay)
            .disposed(by: disposeBag)
    }()
    
    private let balanceProvider: BalanceProviding
    private let balanceChangeProvider: BalanceChangeProviding
    private let changeRelay = BehaviorRelay<PortfolioBalanceChange>(value: .zero)
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(balanceProvider: BalanceProviding,
                balanceChangeProvider: BalanceChangeProviding) {
        self.balanceProvider = balanceProvider
        self.balanceChangeProvider = balanceChangeProvider
    }
    
}
