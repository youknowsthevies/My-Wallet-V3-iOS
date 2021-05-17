// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import RxSwift
import SettingsKit

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
