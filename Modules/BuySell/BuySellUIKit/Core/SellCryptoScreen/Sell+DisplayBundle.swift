//
//  Sell+DisplayBundle.swift
//  BuySellUIKit
//
//  Created by Daniel on 05/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import ToolKit
import PlatformKit
import PlatformUIKit

extension EnterAmountScreenPresenter.DisplayBundle {
    
    static func sell(cryptoCurrency: CryptoCurrency) -> EnterAmountScreenPresenter.DisplayBundle {
        
        typealias LocalizedString = LocalizationConstants.SimpleBuy.SellCryptoScreen
        typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
        typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.SellScreen
        
        return EnterAmountScreenPresenter.DisplayBundle(
            strings: Strings(
                title: "\(LocalizedString.titlePrefix) \(cryptoCurrency.code)",
                ctaButton: LocalizedString.ctaButton,
                bottomAuxiliaryItemSeparatorTitle: ""
            ),
            colors: Colors(
                digitPadTopSeparator: .lightBorder,
                bottomAuxiliaryItemSeparator: .clear
            ),
            // TODO: Daniel - Events
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
                bottomAuxiliaryItemSeparatorTitle: ""
            ),
            amountDisplayBundle: .init(
                events: .init(
                    min: AnalyticsEvent.sbBuyFormMinClicked,
                    max: AnalyticsEvent.sbBuyFormMaxClicked
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

