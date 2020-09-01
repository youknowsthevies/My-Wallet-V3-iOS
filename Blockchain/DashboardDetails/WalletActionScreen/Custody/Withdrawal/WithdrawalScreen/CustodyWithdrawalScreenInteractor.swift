//
//  CustodyWithdrawalScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CustodyWithdrawalScreenInteractor {
    
    enum InteractionState: Equatable {
        
        /// The necessary data for the withdrawal is being fetched
        case settingUp
        
        /// The data for the withdrawal to be submitted is loaded
        case loaded
        
        /// The withdrawal is being submitted
        case submitting
        
        /// The withdrawal has been submitted
        case submitted
        
        /// There was an error submitting the withdrawal
        case error(WithdrawalError)
        
        /// The user has a zero balance
        case insufficientFunds
        
        var isReady: Bool {
            self == .loaded
        }
        
        var isSubmitting: Bool {
            self == .submitting
        }
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
    
    let selectionRelay = PublishRelay<Void>()
    let assetBalanceInteractor: AssetBalanceTypeViewInteracting
    let withdrawalRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        Observable
            .combineLatest(
                setupInteractor.state,
                submissionInteractor.state
            ) { (setupState: $0, submissionState: $1) }
            .map { payload -> InteractionState in
                switch (payload.setupState, payload.submissionState) {
                case (.loading, .ready):
                    return .settingUp
                case (.loaded(let value), .ready):
                    if !value.withdrawableBalance.isPositive {
                        return .insufficientFunds
                    }
                    return .loaded
                case (.loaded, .calculating):
                    return .submitting
                case (.loaded, .value):
                    return .submitted
                case (.loaded, .failed(let error)):
                    return .error(error)
                default:
                    return .settingUp
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        let payloadObservable = setupInteractor.state.compactMap { $0.value }
        
        withdrawalRelay
            .withLatestFrom(payloadObservable)
            .map { value -> (CryptoValue, String) in
                (value.withdrawableBalance, value.destination)
            }
            .bindAndCatch(weak: self, onNext: { (self, values) in
                self.submissionInteractor.submitWithdrawal(
                    cryptoValue: values.0,
                    destination: values.1
                )
            })
            .disposed(by: disposeBag)
    }()

    private let stateRelay = BehaviorRelay<InteractionState>(value: .settingUp)

    private let setupInteractor: CustodyWithdrawalSetupInteractor
    private let submissionInteractor: CustodyWithdrawalSubmissionInteractor
    private let disposeBag = DisposeBag()

    init(withdrawalService: CustodyWithdrawalServiceAPI,
         currency: CryptoCurrency,
         balanceFetching: AssetBalanceFetching,
         tradingBalanceService: TradingBalanceServiceAPI = resolve(),
         accountRepository: AssetAccountRepositoryAPI,
         exchangeProviding: ExchangeProviding = resolve()) {
        let withdrawableAssetBalanceFetcher = WithdrawableAssetBalanceFetcher(
            cryptoCurrency: currency,
            trading: balanceFetching.trading,
            savings: balanceFetching.savings,
            exchange: exchangeProviding[currency]
        )
        assetBalanceInteractor = AssetBalanceTypeViewInteractor(
            assetBalanceFetching: withdrawableAssetBalanceFetcher,
            balanceType: .custodial(.trading)
        )
        setupInteractor = CustodyWithdrawalSetupInteractor(
            currency: currency,
            tradingBalanceService: tradingBalanceService,
            accountRepository: accountRepository
        )
        submissionInteractor = CustodyWithdrawalSubmissionInteractor(withdrawalService: withdrawalService)
    }
}
