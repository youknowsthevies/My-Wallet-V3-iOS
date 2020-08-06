//
//  EnterAmountScreenPresenter+DisplayBundle.swift
//  PlatformUIKit
//
//  Created by Daniel on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import ToolKit
import PlatformKit

extension EnterAmountScreenPresenter {

    /// Contains localized strings, analytics events and accessibility identifiers
    public struct DisplayBundle {
        
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
        public let events: Events
        public let accessibilityIdentifiers: AccessibilityIdentifiers
        
        public init(strings: Strings, events: Events, accessibilityIdentifiers: AccessibilityIdentifiers) {
            self.strings = strings
            self.events = events
            self.accessibilityIdentifiers  = accessibilityIdentifiers
        }
    }
}
