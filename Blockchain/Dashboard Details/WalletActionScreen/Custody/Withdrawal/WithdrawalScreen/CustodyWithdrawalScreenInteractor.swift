//
//  CustodyWithdrawalScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class CustodyWithdrawalScreenInteractor {
    
    enum InteractionState {
        
        /// The necessary data for the withdrawal is being fetched
        case settingUp
        
        /// The data for the withdrawal to be submitted is loaded
        case loaded
        
        /// The withdrawal is being submitted
        case submitting
        
        /// The withdrawal has been submitted
        case submitted
        
        /// There was an error submitting the withdrawal
        case error
        
        var isReady: Bool {
            return self == .loaded
        }
        
        var isSubmitting: Bool {
            return self == .submitting
        }
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .settingUp)
    
    let selectionRelay = PublishRelay<Void>()
    let assetBalanceInteractor: AssetBalanceTypeViewInteracting
    let withdrawalRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private let setupInteractor: CustodyWithdrawalSetupInteractor
    private let submissionInteractor: CustodyWithdrawalSubmissionInteractor
    private let disposeBag = DisposeBag()
    
    init(withdrawalService: CustodyWithdrawalServiceAPI,
         balanceFetching: AssetBalanceFetching,
         currency: CryptoCurrency,
         accountRepository: AssetAccountRepositoryAPI) {
        assetBalanceInteractor = AssetBalanceTypeViewInteractor(
            assetBalanceFetching: balanceFetching,
            balanceType: .custodial
        )
        setupInteractor = CustodyWithdrawalSetupInteractor(
            currency: currency,
            balanceFetching: balanceFetching,
            accountRepository: accountRepository
        )
        submissionInteractor = CustodyWithdrawalSubmissionInteractor(withdrawalService: withdrawalService)
        
        Observable
            .combineLatest(
                setupInteractor.state,
                submissionInteractor.state
            )
            .map { payload -> InteractionState in
                let setupState = payload.0
                let submissionState = payload.1
                switch (setupState, submissionState) {
                case (.loading, .ready):
                    return .settingUp
                case (.loaded, .ready):
                    return .loaded
                case (.loaded, .calculating):
                    return .submitting
                case (.loaded, .value):
                    return .submitted
                case (.loaded, .failed):
                    return .error
                default:
                    return .settingUp
                }
            }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        let payloadObservable = setupInteractor.state.compactMap { $0.value }
        
        withdrawalRelay
            .withLatestFrom(payloadObservable)
            .map { value -> (CryptoValue, String) in
                (value.balance, value.destination)
            }
            .bind(weak: self, onNext: { (self, values) in
                self.submissionInteractor.submitWithdrawal(
                    cryptoValue: values.0,
                    destination: values.1
                )
            })
            .disposed(by: disposeBag)
    }
}
