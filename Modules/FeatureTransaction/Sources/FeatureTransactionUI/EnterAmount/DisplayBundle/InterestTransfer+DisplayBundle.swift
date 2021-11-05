// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class InterestTransferAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func interestTransfer(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        return DisplayBundle(
            title: LocalizedString.Transfer.transfer + " \(sourceAccount.currencyType.displayCode)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestTransferAnalyticsEvent(),
                    max: InterestTransferAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.Swap.AmountPresenter.LimitView.useMin,
                    useMax: LocalizedString.Swap.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
