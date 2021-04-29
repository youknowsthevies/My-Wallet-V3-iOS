// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

/// The interaction layer implementation for fee calculation during the send flow.
final class SendFeeInteractor: SendFeeInteracting {

    // MARK: - Exposed Properties
    
    /// Streams the calculation state for the fee
    var calculationState: Observable<MoneyValuePairCalculationState> {
        calculationStateRelay.asObservable()
    }
    
    // MARK: - Private Properties
    
    private let calculationStateRelay = BehaviorRelay<MoneyValuePairCalculationState>(value: .calculating)
    private let disposeBag = DisposeBag()
    
    // MARK: - Services

    /// The fee service that provides the fee as per asset
    private let feeService: SendFeeServicing
    
    /// The exchange service that provides crypto-fiat exchange rate
    private let exchangeService: PairExchangeServiceAPI
    
    // MARK: - Setup
    
    init(feeService: SendFeeServicing,
         exchangeService: PairExchangeServiceAPI) {
        self.feeService = feeService
        self.exchangeService = exchangeService
        
        // Combine the latest fee and exchange rate and continuous stream status updates
        Observable
            .combineLatest(feeService.fee, exchangeService.fiatPrice)
            .map { (fee, rate) -> MoneyValuePairCalculationState in
                .value(MoneyValuePair(base: fee, exchangeRate: rate))
            }
            .startWith(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: disposeBag)
    }
}
