//
//  CustodyWithdrawalSubmissionInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class CustodyWithdrawalSubmissionInteractor {
    
    enum InteractionState {
        case ready
        case calculating
        case value(CustodialWithdrawalResponse)
        case failed(WithdrawalError)
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
            .observeOn(MainScheduler.instance)
    }
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .ready)
    
    // MARK: - Private Properties
    
    private unowned let withdrawalService: CustodyWithdrawalServiceAPI
    private let disposeBag = DisposeBag()
    
    init(withdrawalService: CustodyWithdrawalServiceAPI) {
        self.withdrawalService = withdrawalService
    }
    
    func submitWithdrawal(cryptoValue: CryptoValue, destination: String) {
        withdrawalService.makeWithdrawal(amount: cryptoValue, destination: destination)
            .map { response -> InteractionState in
                .value(response)
            }
            .catchError { error -> Single<InteractionState> in
                guard let withdrawalError = error as? WithdrawalError else {
                    return .just(.failed(WithdrawalError.unknown))
                }
                return .just(.failed(withdrawalError))
            }
            .asObservable()
            .startWith(.calculating)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
