//
//  Buy+DisplayBundle.swift
//  BuySellUIKit
//
//  Created by Daniel on 04/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import ToolKit
import PlatformKit
import PlatformUIKit

extension EnterAmountScreenPresenter.DisplayBundle {
    
    static var buy: EnterAmountScreenPresenter.DisplayBundle {
        
        typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen
        typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
        typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.BuyScreen
        
        return EnterAmountScreenPresenter.DisplayBundle(
            strings: Strings(
                title: LocalizedString.title,
                ctaButton: LocalizedString.ctaButton,
                bottomAuxiliaryItemSeparatorTitle: LocalizedString.paymentMethodTitle
            ),
            colors: Colors(
                digitPadTopSeparator: .lightBorder,
                bottomAuxiliaryItemSeparator: .lightBorder
            ),
            events: Events(
                didAppear: AnalyticsEvent.sbBuyFormShown,
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
            ),
            accessibilityIdentifiers: AccessibilityIdentifiers(
                bottomAuxiliaryItemSeparatorTitle: AccessibilityId.paymentMethodTitle
            ),
            amountDisplayBundle: .init(
                events: .init(
                    min: AnalyticsEvent.sbBuyFormMinClicked,
                    max: AnalyticsEvent.sbBuyFormMaxClicked
                ),
                strings: .init(
                    useMin: LocalizedString.LimitView.Buy.Min.useMin,
                    useMax: LocalizedString.LimitView.Buy.Max.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
