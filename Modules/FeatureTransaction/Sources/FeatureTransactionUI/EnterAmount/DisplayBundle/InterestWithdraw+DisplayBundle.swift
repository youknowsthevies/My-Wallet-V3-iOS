// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class InterestWithdrawAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func interestWithdraw(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Interest.Screen.EnterAmount.Withdraw
        let code = sourceAccount.currencyType.displayCode
        return DisplayBundle(
            title: LocalizedString.title + " \(code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: InterestWithdrawAnalyticsEvent(),
                    max: InterestWithdrawAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.useMin,
                    useMax: LocalizedString.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
