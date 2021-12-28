// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization

private typealias L10n = LocalizationConstants.NewKYC.UnlockTrading

struct UnlockTradingViewModel: Equatable {

    struct Benefit: Equatable {
        let title: String
        let message: String
        let iconName: String
    }

    struct Action: Equatable {
        enum ActionStyle: Equatable {
            case primary
            case secondary
        }

        let title: String
        let style: ActionStyle
        let action: (ViewStore<UnlockTradingState, UnlockTradingAction>) -> Void

        static func == (lhs: UnlockTradingViewModel.Action, rhs: UnlockTradingViewModel.Action) -> Bool {
            lhs.title == rhs.title && lhs.style == rhs.style
        }
    }

    let title: String
    let message: String
    let viewIconName: String
    let topBackgroundImageName: String?
    let benefits: [Benefit]
    let actions: [Action]
}

extension UnlockTradingViewModel {

    static let unlockGoldTier = UnlockTradingViewModel(
        title: L10n.title,
        message: L10n.message,
        viewIconName: "icon-bank",
        topBackgroundImageName: "top-screen-pattern",
        benefits: [
            Benefit(
                title: L10n.benefitCashAccounts_title,
                message: L10n.benefitCashAccounts_message,
                iconName: "icon-cash"
            ),
            Benefit(
                title: L10n.benefitLinkBankAccounts_title,
                message: L10n.benefitLinkBankAccounts_message,
                iconName: "icon-bank"
            ),
            Benefit(
                title: L10n.benefitEarnRewards_title,
                message: L10n.benefitEarnRewards_message,
                iconName: "icon-interest"
            )
        ],
        actions: [
            Action(
                title: L10n.ctaApplyToUnlock,
                style: .primary,
                action: { viewStore in
                    viewStore.send(.unlockButtonTapped)
                }
            )
        ]
    )
}
