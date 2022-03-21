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
    private let cardIssuingPresenter: CardIssuingCellPresenter

    init(
        tiersLimitsProvider: TierLimitsProviding,
        emailVerificationInteractor: EmailVerificationBadgeInteractor,
        mobileVerificationInteractor: MobileVerificationBadgeInteractor,
        cardIssuingInteractor: CardIssuingBadgeInteractor,
        cardIssuingAdapter: CardIssuingAdapterAPI
    ) {
        limitsPresenter = TierLimitsCellPresenter(tiersProviding: tiersLimitsProvider)
        emailVerificationPresenter = .init(interactor: emailVerificationInteractor)
        mobileVerificationPresenter = .init(interactor: mobileVerificationInteractor)
        cardIssuingPresenter = .init(interactor: cardIssuingInteractor)
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

        let cardIssuingCellModelDisplay = SettingsCellViewModel(cellType: .common(.cardIssuing))
        let cardIssuingCellModelOrder = SettingsCellViewModel(cellType: .badge(.cardIssuing, cardIssuingPresenter))

        state = Publishers
            .CombineLatest(
                cardIssuingAdapter.isEnabled(),
                cardIssuingAdapter.hasCard()
            )
            .map { cardIssuingEnabled, hasCard -> SettingsSectionLoadingState in
                if let index = viewModel.items.firstIndex(of: cardIssuingCellModelDisplay) {
                    viewModel.items.remove(at: index)
                }

                if let index = viewModel.items.firstIndex(of: cardIssuingCellModelOrder) {
                    viewModel.items.remove(at: index)
                }

                switch (cardIssuingEnabled, hasCard) {
                case (_, true):
                    viewModel.items.append(cardIssuingCellModelDisplay)
                case (true, false):
                    viewModel.items.append(cardIssuingCellModelOrder)
                case (false, false):
                    break
                }

                return .loaded(next: .some(viewModel))
            }
            .asObservable()
    }
}
