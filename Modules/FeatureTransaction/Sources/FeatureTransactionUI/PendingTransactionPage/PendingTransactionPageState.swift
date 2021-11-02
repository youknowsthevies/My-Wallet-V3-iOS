// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

struct PendingTransactionPageState {

    enum Effect {

        /// Dismiss the pending screen.
        case close

        /// Show KYC upgrade prompt
        case upgradeKYCTier

        /// Do nothing. This is usually only
        /// present when the screen is pending
        /// as opposed to a success or failure state.
        case none
    }

    let title: LabelContent
    let subtitle: LabelContent
    let compositeViewType: CompositeStatusViewType
    let effect: Effect
    let primaryButtonViewModel: ButtonViewModel?
    let secondaryButtonViewModel: ButtonViewModel?

    static let empty: PendingTransactionPageState = .init(
        title: "",
        subtitle: ""
    )

    init(
        title: String,
        subtitle: String,
        compositeViewType: CompositeStatusViewType = .none,
        effect: Effect = .none,
        primaryButtonViewModel: ButtonViewModel? = nil,
        secondaryButtonViewModel: ButtonViewModel? = nil
    ) {
        self.title = .init(
            text: title,
            font: .main(.semibold, 20.0),
            color: .titleText,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionTitleLabel")
        )

        self.subtitle = .init(
            text: subtitle,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionSubtitleLabel")
        )

        self.compositeViewType = compositeViewType
        self.primaryButtonViewModel = primaryButtonViewModel
        self.secondaryButtonViewModel = secondaryButtonViewModel
        self.effect = effect
    }
}

extension PendingTransactionPageState {

    var primaryButtonViewModelVisibility: Visibility {
        primaryButtonViewModel == nil ? .hidden : .visible
    }

    var secondaryButtonViewModelVisibility: Visibility {
        secondaryButtonViewModel == nil ? .hidden : .visible
    }
}
