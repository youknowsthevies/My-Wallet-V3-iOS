// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
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
        let topSelectionFromIdentifier: String
        let topSelectionToIdentifier: String
        let bottomAuxiliaryItemSeparatorTitle: String

        init(bottomAuxiliaryItemSeparatorTitle: String, topSelectionFromIdentifier: String, topSelectionToIdentifier: String) {
            self.bottomAuxiliaryItemSeparatorTitle = bottomAuxiliaryItemSeparatorTitle
            self.topSelectionFromIdentifier = topSelectionFromIdentifier
            self.topSelectionToIdentifier = topSelectionToIdentifier
        }
    }

    let title: String
    let amountDisplayBundle: AmountTranslationPresenter.DisplayBundle
    let colors: Colors
    let events: Events
    let accessibilityIdentifiers: AccessibilityIdentifiers

    init(title: String,
         colors: Colors,
         events: Events,
         accessibilityIdentifiers: AccessibilityIdentifiers,
         amountDisplayBundle: AmountTranslationPresenter.DisplayBundle) {
        self.title = title
        self.colors = colors
        self.events = events
        self.accessibilityIdentifiers  = accessibilityIdentifiers
        self.amountDisplayBundle = amountDisplayBundle
    }

    static func bundle(for action: AssetAction, sourceAccount: SingleAccount) -> DisplayBundle {
        switch action {
        case .swap:
            return .swap(sourceAccount: sourceAccount)
        case .send,
             .withdraw:
            return .send(sourceAccount: sourceAccount)
        case .deposit,
             .receive,
             .sell,
             .viewActivity:
            unimplemented()
        }
    }
}
