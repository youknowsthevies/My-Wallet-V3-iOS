// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

struct TargetSelectionCardModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Transaction.TargetSource.SendToDomainCard

    let identifier: String
    let title: String
    let subtitle: String

    static var sendToDomains: TargetSelectionCardModel {
        TargetSelectionCardModel(
            identifier: "transaction-flow.target.domain-card",
            title: LocalizedString.title,
            subtitle: LocalizedString.subtitle
        )
    }
}
