// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class BalanceChangeViewInteractor: AssetPriceViewInteracting {
    
    public typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction

    // MARK: - Exposed Properties
    
    public var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private lazy var setup: Void = {
        Observable
            .combineLatest(balanceProvider.fiatBalance, balanceChangeProvider.change)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { (balance, change) -> InteractionState in
                guard let currentBalance = balance.value else { return .loading }
                guard change.containsValue else { return .loading }
                guard let changeValue = change.totalFiat.value else { return .loading }
                
                let percentage: Decimal // in range [0...1]
                if currentBalance.isZero {
                    percentage = 0
                } else {
                    let previousBalance = try currentBalance - changeValue
                    
                    /// `zero` shouldn't be possible but is handled in any case
                    /// in a way that would not throw
                    if previousBalance.isZero || previousBalance.isNegative {
                        percentage = 0
                    } else {
                        percentage = try changeValue.percentage(of: previousBalance)
                    }
                }
                return .loaded(
                    next: .init(
                        time: .hours(24),
                        fiatValue: currentBalance,
                        changePercentage: percentage.doubleValue,
                        fiatChange: changeValue
                    )
                )
            }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    
    private let balanceProvider: BalanceProviding
    private let balanceChangeProvider: BalanceChangeProviding
    
    // MARK: - Setup
    
    public init(balanceProvider: BalanceProviding,
                balanceChangeProvider: BalanceChangeProviding) {
        self.balanceProvider = balanceProvider
        self.balanceChangeProvider = balanceChangeProvider
    }
}
