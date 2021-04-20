//
//  Send+DisplayBundle.swift
//  TransactionUIKit
//
//  Created by Alex McGregor on 2/16/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class SendAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func send(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        let colors = Colors(
            digitPadTopSeparator: .lightBorder,
            bottomAuxiliaryItemSeparator: .clear
        )

        // TODO: Add correct Analytics Event
        let events = Events(
            didAppear: SendAnalyticsEvent(),
            confirmSuccess: SendAnalyticsEvent(),
            confirmFailure: SendAnalyticsEvent(),
            confirmTapped: { _, _, _ in SendAnalyticsEvent() },
            sourceAccountChanged: { _ in SendAnalyticsEvent() }
        )

        let accessibilityIdentifiers = AccessibilityIdentifiers(
            bottomAuxiliaryItemSeparatorTitle: "",
            topSelectionFromIdentifier: "Send.From.Selection",
            topSelectionToIdentifier: "Send.To.Selection"
        )

        return DisplayBundle(
            title: LocalizedString.Send.send,
            colors: colors,
            events: events,
            accessibilityIdentifiers: accessibilityIdentifiers,
            amountDisplayBundle: .init(
                events: .init(
                    min: SendAnalyticsEvent(),
                    max: SendAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.Send.AmountPresenter.LimitView.useMin,
                    useMax: LocalizedString.Send.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}

