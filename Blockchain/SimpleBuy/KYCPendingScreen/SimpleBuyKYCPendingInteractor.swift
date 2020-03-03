//
//  SimpleBuyKYCPendingInteractor.swift
//  Blockchain
//
//  Created by Paulo on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import ToolKit
import PlatformKit
import PlatformUIKit

final class SimpleBuyKYCPendingInteractor {

    // MARK: - Properties

    var verificationState: Observable<SimpleBuyKYCPendingVerificationState> {
        verificationStateRelay.asObservable()
    }
    
    private let eligibilityService: SimpleBuyEligibilityServiceAPI
    private let kycTiersService: KYCTierUpdatePollingService
    private let disposeBag = DisposeBag()

    private let verificationStateRelay = BehaviorRelay<SimpleBuyKYCPendingVerificationState>(value: .loading)

    // MARK: - Setup
    
    init(kycTiersService: KYCTierUpdatePollingService,
         eligibilityService: SimpleBuyEligibilityServiceAPI) {
        self.kycTiersService = kycTiersService
        self.eligibilityService = eligibilityService
    }
    
    func startPollingForGoldTier() {
        kycTiersService
            .poll(untilTier: .tier2, is: .approved, timeoutAfter: 30)
            .map { $0.verificationState }
            .flatMap(weak: self) { (self, state) -> Single<SimpleBuyKYCPendingVerificationState> in
                guard state == .completed else {
                    return .just(state)
                }
                return self.eligibilityService.fetch()
                    .take(1)
                    .asSingle()
                    .map { $0 ? .completed : .ineligible }
            }
            .subscribe(
                onSuccess: { [weak verificationStateRelay] newState in
                    verificationStateRelay?.accept(newState)
                },
                onError: { [weak verificationStateRelay] _ in
                    verificationStateRelay?.accept(.pending)
                }
            )
            .disposed(by: disposeBag)
    }
}

fileprivate extension KYC.AccountStatus {
    var verificationState: SimpleBuyKYCPendingVerificationState {
        switch self {
        case .approved:
            return .completed
        case .failed:
            return .manualReview
        case .pending, .underReview:
            return .pending
        case .expired, .none:
            return .pending
        }
    }
}
