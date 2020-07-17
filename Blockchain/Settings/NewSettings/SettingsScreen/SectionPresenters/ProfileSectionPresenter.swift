//
//  ProfileSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/15/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class ProfileSectionPresenter: SettingsSectionPresenting {
    
    // MARK: - SettingsSectionPresenting
    
    let sectionType: SettingsSectionType = .profile
    
    var state: Observable<SettingsSectionLoadingState> {
        .just(
            .loaded(next:
                .some(
                    .init(
                        sectionType: sectionType,
                        items: [
                            .init(cellType: .badge(.limits, limitsPresenter)),
                            .init(cellType: .clipboard(.walletID)),
                            .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
                            .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
                            .init(cellType: .plain(.loginToWebWallet))
                        ]
                    )
                )
            )
        )
    }
    
    private let limitsPresenter: TierLimitsCellPresenter
    private let emailVerificationPresenter: EmailVerificationCellPresenter
    private let mobileVerificationPresenter: MobileVerificationCellPresenter
    
    init(tiersLimitsProvider: TierLimitsProviding,
         emailVerificationInteractor: EmailVerificationBadgeInteractor,
         mobileVerificationInteractor: MobileVerificationBadgeInteractor) {
        limitsPresenter = TierLimitsCellPresenter(tiersProviding: tiersLimitsProvider)
        emailVerificationPresenter = .init(interactor: emailVerificationInteractor)
        mobileVerificationPresenter = .init(interactor: mobileVerificationInteractor)
    }
}

