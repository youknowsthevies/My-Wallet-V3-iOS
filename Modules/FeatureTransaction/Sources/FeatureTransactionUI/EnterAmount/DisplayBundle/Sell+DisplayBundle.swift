// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

extension DisplayBundle {

    static func sell(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        return DisplayBundle(
            title: LocalizedString.Sell.title + " \(sourceAccount.currencyType.code)",
            amountDisplayBundle: .init(
                events: nil,
                strings: .init(
                    useMin: LocalizationConstants.Transaction.Sell.AmountPresenter.LimitView.useMin,
                    useMax: LocalizationConstants.Transaction.Sell.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
