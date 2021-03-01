//
//  DisplayBundle+Swap.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 13/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class SwapAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func swap(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        let colors = Colors(
            digitPadTopSeparator: .lightBorder,
            bottomAuxiliaryItemSeparator: .clear
        )

        // TODO: Add correct Analytics Event
        let events = Events(
            didAppear: SwapAnalyticsEvent(),
            confirmSuccess: SwapAnalyticsEvent(),
            confirmFailure: SwapAnalyticsEvent(),
            confirmTapped: { _, _, _ in SwapAnalyticsEvent() },
            sourceAccountChanged: { _ in SwapAnalyticsEvent() }
        )

        let accessibilityIdentifiers = AccessibilityIdentifiers(
            bottomAuxiliaryItemSeparatorTitle: ""
        )

        return DisplayBundle(
            title: LocalizedString.Swap.swap,
            colors: colors,
            events: events,
            accessibilityIdentifiers: accessibilityIdentifiers,
            amountDisplayBundle: .init(
                events: .init(
                    min: SwapAnalyticsEvent(),
                    max: SwapAnalyticsEvent()
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
