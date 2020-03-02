//
//  CustodyWithdrawalSubmissionInteractor.swift
//  Blockchain
//
//  Created by AlexM on 2/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxRelay

final class CustodyWithdrawalSubmissionInteractor {
    
    enum InteractionState {
        case ready
        case calculating
        case value(CustodialWithdrawalResponse)
        case failed
    }
    
    // MARK: - Public Properties
    
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
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
        withdrawalService.makeWithdrawal(amount: cryptoValue, destination: destination).asObservable()
            .map(weak: self, { (self, response) -> InteractionState in
                .value(response)
            })
            .catchErrorJustReturn(.failed)
            .startWith(.calculating)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
