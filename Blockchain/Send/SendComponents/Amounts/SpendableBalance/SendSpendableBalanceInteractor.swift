// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

/// The interaction layer implementation for spendable balance on the send screen
final class SendSpendableBalanceInteractor: SendSpendableBalanceInteracting {
    
    // MARK: - Exposed Properties
    
    /// Streams the spendable balance
    var calculationState: Observable<MoneyValuePairCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let calculationStateRelay = BehaviorRelay<MoneyValuePairCalculationState>(value: .calculating)

    private let disposeBag = DisposeBag()

    // MARK: - Services
    
    private let balanceFetcher: SingleAccountBalanceFetching
    private let feeInteractor: SendFeeInteracting
    private let exchangeService: PairExchangeServiceAPI
    
    // MARK: - Setup
    
    init(balanceFetcher: SingleAccountBalanceFetching,
         feeInteractor: SendFeeInteracting,
         exchangeService: PairExchangeServiceAPI) {
        self.balanceFetcher = balanceFetcher
        self.feeInteractor = feeInteractor
        self.exchangeService = exchangeService
        
        let fee = feeInteractor.calculationState
            .compactMap { $0.value }
            .map { $0.base }
        let balance = balanceFetcher
            .balanceMoneyObservable
        let exchangeRate = exchangeService.fiatPrice
            .map { $0.moneyValue }
        
        // Calculate the balance and fetch the fiat price exchange,
        // while starting as `.calculating` state.
        // Combine-latest is the most reliable option to get stream of updated values
        // once all are calculated and any of them emits a new one.
        Observable
            .combineLatest(
                balance,
                exchangeRate,
                fee
            )
            .map { (balance, exchangeRate, fee) -> MoneyValuePair in
                // Addition cannot fail as the fee and balance use the same underlying asset
                var spendableBalance = try balance - fee
                let zero = MoneyValue.zero(currency: spendableBalance.currencyType)
                if try spendableBalance < zero {
                    spendableBalance = zero
                }
                return try MoneyValuePair(base: spendableBalance, exchangeRate: exchangeRate)
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
