//
//  DisplayBundle.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 13/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

struct DisplayBundle {

    struct Colors {
        let digitPadTopSeparator: Color
        let bottomAuxiliaryItemSeparator: Color

        init(digitPadTopSeparator: Color,
             bottomAuxiliaryItemSeparator: Color) {
            self.digitPadTopSeparator = digitPadTopSeparator
            self.bottomAuxiliaryItemSeparator = bottomAuxiliaryItemSeparator
        }
    }

    struct Events {
        let didAppear: AnalyticsEvent
        let confirmSuccess: AnalyticsEvent
        let confirmFailure: AnalyticsEvent
        let confirmTapped: (CurrencyType, MoneyValue, [String: String]) -> AnalyticsEvent
        let sourceAccountChanged: (String) -> AnalyticsEvent

        init(didAppear: AnalyticsEvent,
             confirmSuccess: AnalyticsEvent,
             confirmFailure: AnalyticsEvent,
             confirmTapped: @escaping (CurrencyType, MoneyValue, [String: String]) -> AnalyticsEvent,
             sourceAccountChanged: @escaping (String) -> AnalyticsEvent) {
            self.didAppear = didAppear
            self.confirmSuccess = confirmSuccess
            self.confirmFailure = confirmFailure
            self.confirmTapped = confirmTapped
            self.sourceAccountChanged = sourceAccountChanged
        }
    }

    struct AccessibilityIdentifiers {
        let bottomAuxiliaryItemSeparatorTitle: String

        init(bottomAuxiliaryItemSeparatorTitle: String) {
            self.bottomAuxiliaryItemSeparatorTitle = bottomAuxiliaryItemSeparatorTitle
        }
    }

    let amountDisplayBundle: AmountTranslationPresenter.DisplayBundle
    let colors: Colors
    let events: Events
    let accessibilityIdentifiers: AccessibilityIdentifiers

    init(colors: Colors,
         events: Events,
         accessibilityIdentifiers: AccessibilityIdentifiers,
         amountDisplayBundle: AmountTranslationPresenter.DisplayBundle) {
        self.colors = colors
        self.events = events
        self.accessibilityIdentifiers  = accessibilityIdentifiers
        self.amountDisplayBundle = amountDisplayBundle
    }
}
