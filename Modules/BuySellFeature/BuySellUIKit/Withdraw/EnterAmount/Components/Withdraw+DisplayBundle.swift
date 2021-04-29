// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

struct DisplayBundle {

    public struct Colors {
        public let digitPadTopSeparator: Color
        public let bottomAuxiliaryItemSeparator: Color

        public init(digitPadTopSeparator: Color,
                    bottomAuxiliaryItemSeparator: Color) {
            self.digitPadTopSeparator = digitPadTopSeparator
            self.bottomAuxiliaryItemSeparator = bottomAuxiliaryItemSeparator
        }
    }

    public struct Events {
        public let didAppear: AnalyticsEvent
        public let minTapped: AnalyticsEvent
        public let maxTapped: AnalyticsEvent
        public let confirmSuccess: AnalyticsEvent
        public let confirmFailure: AnalyticsEvent
        public let confirmTapped: (CurrencyType, MoneyValue, [String: String]) -> AnalyticsEvent
        public let sourceAccountChanged: (String) -> AnalyticsEvent

        public init(didAppear: AnalyticsEvent,
                    minTapped: AnalyticsEvent,
                    maxTapped: AnalyticsEvent,
                    confirmSuccess: AnalyticsEvent,
                    confirmFailure: AnalyticsEvent,
                    confirmTapped: @escaping (CurrencyType, MoneyValue, [String: String]) -> AnalyticsEvent,
                    sourceAccountChanged: @escaping (String) -> AnalyticsEvent) {
            self.didAppear = didAppear
            self.minTapped = minTapped
            self.maxTapped = maxTapped
            self.confirmSuccess = confirmSuccess
            self.confirmFailure = confirmFailure
            self.confirmTapped = confirmTapped
            self.sourceAccountChanged = sourceAccountChanged
        }
    }

    public struct Strings {
        public let title: String
        public let ctaButton: String
        public let bottomAuxiliaryItemSeparatorTitle: String
        public let useMin: String
        public let useMax: String

        public init(title: String,
                    ctaButton: String,
                    bottomAuxiliaryItemSeparatorTitle: String,
                    useMin: String,
                    useMax: String) {
            self.title = title
            self.ctaButton = ctaButton
            self.bottomAuxiliaryItemSeparatorTitle = bottomAuxiliaryItemSeparatorTitle
            self.useMin = useMin
            self.useMax = useMax
        }
    }

    public struct AccessibilityIdentifiers {
        public let bottomAuxiliaryItemSeparatorTitle: String

        public init(bottomAuxiliaryItemSeparatorTitle: String) {
            self.bottomAuxiliaryItemSeparatorTitle = bottomAuxiliaryItemSeparatorTitle
        }
    }

    public let strings: Strings
    public let colors: Colors
    public let events: Events
    public let accessibilityIdentifiers: AccessibilityIdentifiers

    public init(strings: Strings,
                colors: Colors,
                events: Events,
                accessibilityIdentifiers: AccessibilityIdentifiers) {
        self.strings = strings
        self.colors = colors
        self.events = events
        self.accessibilityIdentifiers  = accessibilityIdentifiers
    }
}

extension DisplayBundle {

    static func withdraw(currency: Currency) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.FiatWithdrawal.EnterAmountScreen
        typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
        typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.SellScreen

        let strings = Strings(
            title: String(format: LocalizedString.title, currency.code),
            ctaButton: LocalizedString.ctaButton,
            bottomAuxiliaryItemSeparatorTitle: "",
            useMin: "",
            useMax: LocalizedString.useMax
        )

        let colors = Colors(
            digitPadTopSeparator: .lightBorder,
            bottomAuxiliaryItemSeparator: .clear
        )

        // TODO: Add correct Analytics Event
        let events = Events(
            didAppear: AnalyticsEvent.sbBuyFormShown,
            minTapped: AnalyticsEvent.sbBuyFormMinClicked,
            maxTapped: AnalyticsEvent.sbBuyFormMaxClicked,
            confirmSuccess: AnalyticsEvent.sbBuyFormConfirmSuccess,
            confirmFailure: AnalyticsEvent.sbBuyFormConfirmFailure,
            confirmTapped: { (currencyType, amount, additionalParameters) in
                AnalyticsEvent.sbBuyFormConfirmClick(
                    currencyCode: currencyType.code,
                    amount: amount.toDisplayString(includeSymbol: true),
                    additionalParameters: additionalParameters
                )
            },
            sourceAccountChanged: { AnalyticsEvent.sbBuyFormCryptoChanged(asset: $0) }
        )
        let accessibilityIdentifiers = AccessibilityIdentifiers(
            bottomAuxiliaryItemSeparatorTitle: ""
        )

        return DisplayBundle(
            strings: strings,
            colors: colors,
            events: events,
            accessibilityIdentifiers: accessibilityIdentifiers
        )
    }
}
