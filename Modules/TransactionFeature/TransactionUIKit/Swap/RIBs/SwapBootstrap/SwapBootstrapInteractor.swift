// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import KYCKit
import KYCUIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

protocol SwapBootstrapRouting: ViewableRouting {
}

protocol SwapBootstrapPresentable: Presentable {
    func showLoading()
}

protocol SwapBootstrapListener: AnyObject {
    func userMustKYCForSwap()
    func userMustCompleteKYC(model: KYCTiersPageModel)
    func userReadyForSwap()
}

final class SwapBootstrapInteractor: PresentableInteractor<SwapBootstrapPresentable>, SwapBootstrapInteractable {

    private enum Effect {
        case userMustKYCForSwap
        case userMustCompleteKYC(KYCTiersPageModel)
        case userReadyForSwap
    }

    weak var router: SwapBootstrapRouting?
    weak var listener: SwapBootstrapListener?

    private let kycTiersService: KYCTiersServiceAPI
    private let kycSettings: KYCSettingsAPI
    private let kycTiersPageModelFactory: KYCTiersPageModelFactoryAPI

    init(presenter: SwapBootstrapPresentable,
         kycSettings: KYCSettingsAPI = resolve(),
         kycTiersService: KYCTiersServiceAPI = resolve(),
         kycTiersPageModelFactory: KYCTiersPageModelFactoryAPI = resolve()) {
        self.kycTiersService = kycTiersService
        self.kycSettings = kycSettings
        self.kycTiersPageModelFactory = kycTiersPageModelFactory
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        checkStatus()
    }

    private func checkStatus() {
        let isCompletingKyc: Single<Bool> = kycSettings.isCompletingKyc
        let hasAnyApprovedKYCTier: Single<Bool> = kycTiersService
            .fetchTiers()
            .map { $0.latestApprovedTier > .tier0 }

        Single.zip(hasAnyApprovedKYCTier, isCompletingKyc)
            .observeOn(MainScheduler.asyncInstance)
            .do(onSubscribe: { [weak presenter] in
                presenter?.showLoading()
            })
            .flatMap(weak: self) { (self, payload) -> Single<Effect> in
                let (hasAnyApprovedKYCTier, isCompletingKyc) = payload
                switch (hasAnyApprovedKYCTier, isCompletingKyc) {
                case (false, false):
                    return .just(.userMustKYCForSwap)
                case (false, true):
                    return self.kycTiersPageModelFactory
                        .tiersPageModel(suppressCTA: true)
                        .map { .userMustCompleteKYC($0) }
                        .observeOn(MainScheduler.asyncInstance)
                case (true, _):
                    return .just(.userReadyForSwap)
                }
            }
            .subscribe(
                onSuccess: { [weak self] effect in
                    guard let self = self else { return }
                    switch effect {
                    case .userMustKYCForSwap:
                        self.listener?.userMustKYCForSwap()
                    case .userMustCompleteKYC(let model):
                        self.listener?.userMustCompleteKYC(model: model)
                    case .userReadyForSwap:
                        self.listener?.userReadyForSwap()
                    }
                },
                onError: { error in

                }
            )
            .disposeOnDeactivate(interactor: self)
    }
}
