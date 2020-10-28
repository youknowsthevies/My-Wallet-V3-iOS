//
//  SwapBootstrapInteractor.swift
//  TransactionUIKit
//
//  Created by Paulo on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

protocol SwapBootstrapRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol SwapBootstrapPresentable: Presentable {
    func showLoading()
}

protocol SwapBootstrapListener: class {
    func userIsIneligibleForSwap()
    func userMustKYCForSwap()
    func userReadyForSwap()
}

final class SwapBootstrapInteractor: PresentableInteractor<SwapBootstrapPresentable>, SwapBootstrapInteractable {

    weak var router: SwapBootstrapRouting?
    weak var listener: SwapBootstrapListener?

    private var disposeBag: DisposeBag = DisposeBag()
    private let kycTiersService: KYCTiersServiceAPI
    private let eligibilityService: EligibilityServiceAPI

    init(presenter: SwapBootstrapPresentable,
         kycTiersService: KYCTiersServiceAPI = resolve(),
         eligibilityService: EligibilityServiceAPI = resolve()) {
        self.eligibilityService = eligibilityService
        self.kycTiersService = kycTiersService
        super.init(presenter: presenter)

    }

    override func didBecomeActive() {
        super.didBecomeActive()
        checkStatus()
    }

    private func checkStatus() {
        let tier2Status: Single<KYC.AccountStatus> = kycTiersService
            .fetchTiers()
            .map { $0.tierAccountStatus(for: .tier2) }

        let eligibility: Single<Bool> = eligibilityService
            .fetch()
            .take(1)
            .asSingle()

        Single.zip(tier2Status, eligibility)
            .observeOn(MainScheduler.asyncInstance)
            .do(onSubscribe: { [weak presenter] in
                presenter?.showLoading()
            })
            .subscribe(
                onSuccess: { [weak self] (tier2Status: KYC.AccountStatus, eligibility: Bool) in
                    switch (eligibility, tier2Status.isApproved) {
                    case (false, _):
                        self?.listener?.userIsIneligibleForSwap()
                    case (true, false):
                        self?.listener?.userMustKYCForSwap()
                    case (true, true):
                        self?.listener?.userReadyForSwap()
                    }
                },
                onError: { error in
                    
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        disposeBag = DisposeBag()
        super.willResignActive()
    }
}
