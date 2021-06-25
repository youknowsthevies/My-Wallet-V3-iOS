// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class AccountAuxiliaryViewPresenter {

    // MARK: - Public Properites

    let badgeImageViewModel: Driver<BadgeImageViewModel>
    let titleLabel: Driver<LabelContent>
    let subtitleLabel: Driver<LabelContent>

    // MARK: - Private Properties

    private let interactor: AccountAuxiliaryViewInteractor

    init(interactor: AccountAuxiliaryViewInteractor) {
        self.interactor = interactor
        badgeImageViewModel = interactor
            .blockchainAccountRelay
            .compactMap { $0 as? LinkedBankAccount }
            .map(\.logoResource)
            .map(\.local)
            .map {
                BadgeImageViewModel.default(
                    with: $0.name,
                    bundle: .platformUIKit,
                    cornerRadius: .round,
                    accessibilityIdSuffix: "AccountAuxiliaryViewBadge"
                )
            }
            .asDriverCatchError()

        titleLabel = interactor
            .blockchainAccountRelay
            .map(\.label)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 16.0),
                    color: .titleText,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewTitle")
                )
            }
            .asDriverCatchError()

        subtitleLabel = interactor
            .blockchainAccountRelay
            .compactMap { $0 as? LinkedBankAccount }
            .map(\.accountNumber)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.medium, 14.0),
                    color: .descriptionText,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewSubtitle")
                )
            }
            .asDriverCatchError()
    }
}
