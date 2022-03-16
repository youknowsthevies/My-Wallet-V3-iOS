// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

struct TargetSelectionCardModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Transaction.TargetSource.SendToDomainCard

    let identifier: String
    let title: String
    let subtitle: String
    let didClose: () -> Void

    static func sendToDomains(didClose: @escaping () -> Void) -> TargetSelectionCardModel {
        TargetSelectionCardModel(
            identifier: "transaction-flow.target.domain-card",
            title: LocalizedString.title,
            subtitle: LocalizedString.subtitle,
            didClose: didClose
        )
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
            && lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
    }
}
