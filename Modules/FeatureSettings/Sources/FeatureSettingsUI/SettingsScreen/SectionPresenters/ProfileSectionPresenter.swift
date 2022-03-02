// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import FeatureSettingsDomain
import PlatformKit
import RxSwift
import ToolKit

final class ProfileSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .profile
    var state: Observable<SettingsSectionLoadingState>

    private let limitsPresenter: TierLimitsCellPresenter
    private let emailVerificationPresenter: EmailVerificationCellPresenter
    private let mobileVerificationPresenter: MobileVerificationCellPresenter
    private let cardIssuancePresenter: CardIssuanceCellPresenter

    init(
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        cardIssuanceInteractor: CardIssuanceBadgeInteractor,
        featureFlagsService: FeatureFlagsServiceAPI
    ) {
        limitsPresenter = TierLimitsCellPresenter(tiersProviding: tiersLimitsProvider)
        emailVerificationPresenter = .init(interactor: emailVerificationInteractor)
        mobileVerificationPresenter = .init(interactor: mobileVerificationInteractor)
        cardIssuancePresenter = .init(interactor: cardIssuanceInteractor)
        // IOS: 4806: Hiding the web log in for production build as pair wallet with QR code has been deprecated
        // Web log in is enabled in internal production to ease QA testing
        var viewModel = SettingsSectionViewModel(
            sectionType: sectionType,
            items: [
                .init(cellType: .badge(.limits, limitsPresenter)),
                .init(cellType: .clipboard(.walletID)),
                .init(cellType: .badge(.emailVerification, emailVerificationPresenter)),
                .init(cellType: .badge(.mobileVerification, mobileVerificationPresenter)),
                .init(cellType: .common(.webLogin))
            ]
        )
        if BuildFlag.isInternal {
            viewModel.items.append(.init(cellType: .common(.loginToWebWallet)))
        }

        let cardIssuanceCellModel = SettingsCellViewModel(cellType: .badge(.cardIssuance, cardIssuancePresenter))

        state = Publishers
            .CombineLatest(
                featureFlagsService.isEnabled(.remote(.cardIssuance)),
                featureFlagsService.isEnabled(.local(.cardIssuance))
            )
            .map { $0 || $1 }
            .map { cardIssuanceEnabled -> SettingsSectionLoadingState in
                if cardIssuanceEnabled, !viewModel.items.contains(cardIssuanceCellModel) {
                    viewModel.items.append(cardIssuanceCellModel)
                } else {
                    viewModel.items.removeElementByReference(cardIssuanceCellModel)
                }
                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}
