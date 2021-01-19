//
//  YodleeScreenContentReducer.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 18/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import Localization
import PlatformUIKit

final class YodleeScreenContentReducer {

    // MARK: Pending Content

    typealias LocalizedStrings = LocalizationConstants.SimpleBuy.YodleeWebScreen

    let continueButtonViewModel: ButtonViewModel = .primary(
        with: LocalizedStrings.WebViewSuccessContent.mainActionButtonTitle
    )

    let tryAgainButtonViewModel: ButtonViewModel = .primary(
        with: LocalizedStrings.FailurePendingContent.Generic.mainActionButtonTitle
    )

    let cancelButtonViewModel: ButtonViewModel = .secondary(
        with: LocalizedStrings.FailurePendingContent.Generic.cancelActionButtonTitle
    )

    // MARK: Pending Content

    func webviewSuccessContent(bankName: String?) -> YodleePendingContent {
        var subtitle = LocalizedStrings.WebViewSuccessContent.subtitleGeneric
        if let bankName = bankName {
            subtitle = String(format: LocalizedStrings.WebViewSuccessContent.subtitleWithBankName, bankName)
        }
        return YodleePendingContent(
            compositeViewType: .composite(
                .init(baseViewType: .image("large-bank-icon"),
                      sideViewAttributes: .init(type: .image("v-success-icon"), position: .rightCorner))
            ),
            mainTitleContent: .init(text: LocalizedStrings.WebViewSuccessContent.title,
                                    font: .main(.bold, 20),
                                    color: .darkTitleText,
                                    alignment: .center),
            subtTitleContent: .init(text: subtitle,
                                    font: .main(.regular, 14),
                                    color: .descriptionText,
                                    alignment: .center),
            buttonContent: continueButtonContent()
        )
    }

    func webviewPendingContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(baseViewType: .image("filled_yodlee_logo"),
                      sideViewAttributes: .init(type: .loader, position: .rightCorner))
            ),
            mainTitleContent: .init(text: LocalizedStrings.WebViewPendingContent.title,
                                    font: .main(.bold, 20),
                                    color: .darkTitleText,
                                    alignment: .center),
            subtTitleContent: .init(text: LocalizedStrings.WebViewPendingContent.subtitle,
                                    font: .main(.regular, 14),
                                    color: .descriptionText,
                                    alignment: .center),
            buttonContent: nil
        )
    }

    func webviewFailureContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(baseViewType: .image("filled_blockchain_logo"),
                      sideViewAttributes: .init(type: .image("circular-error-icon"), position: .rightCorner))
            ),
            mainTitleContent: .init(text: LocalizedStrings.FailurePendingContent.Generic.title,
                                    font: .main(.bold, 20),
                                    color: .darkTitleText,
                                    alignment: .center),
            subtTitleContent: .init(text: LocalizedStrings.FailurePendingContent.Generic.subtitle,
                                    font: .main(.regular, 14),
                                    color: .descriptionText,
                                    alignment: .center),
            buttonContent: tryAgainAndCloseButtonContent()
        )
    }

    func linkingBankPendingContent() -> YodleePendingContent {
        YodleePendingContent(
            compositeViewType: .composite(
                .init(baseViewType: .image("filled_blockchain_logo"),
                      sideViewAttributes: .init(type: .loader, position: .rightCorner))
            ),
            mainTitleContent: .init(text: LocalizedStrings.LinkingPendingContent.title,
                                    font: .main(.bold, 20),
                                    color: .darkTitleText,
                                    alignment: .center),
            subtTitleContent: .init(text: LocalizedStrings.LinkingPendingContent.subtitle,
                                    font: .main(.regular, 14),
                                    color: .descriptionText,
                                    alignment: .center),
            buttonContent: nil
        )
    }

    func linkingBankFailureContent(error: LinkedBankData.LinkageError) -> YodleePendingContent {
        let failureTitles = linkingBankFailureTitles(from: error)
        return YodleePendingContent(
            compositeViewType: .composite(
                .init(baseViewType: .image("filled_blockchain_logo"),
                      sideViewAttributes: .init(type: .image("circular-error-icon"), position: .rightCorner))
            ),
            mainTitleContent: .init(text: failureTitles.title,
                                    font: .main(.bold, 20),
                                    color: .darkTitleText,
                                    alignment: .center),
            subtTitleContent: .init(text: failureTitles.subtitle,
                                    font: .main(.regular, 14),
                                    color: .descriptionText,
                                    alignment: .center),
            buttonContent: nil
        )
    }

    // MARK: Button Content

    func tryAgainAndCloseButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: nil,
            tryAgainButtonViewModel: tryAgainButtonViewModel,
            cancelActionButtonViewModel: cancelButtonViewModel
        )
    }

    func continueButtonContent() -> YodleeButtonsContent {
        YodleeButtonsContent(
            identifier: UUID(),
            continueButtonViewModel: continueButtonViewModel,
            tryAgainButtonViewModel: nil,
            cancelActionButtonViewModel: nil
        )
    }

    // MARK: Private

    func linkingBankFailureTitles(from linkageError: LinkedBankData.LinkageError) -> (title: String, subtitle: String) {
        switch linkageError {
        case .alreadyLinked:
            return (LocalizedStrings.FailurePendingContent.AlreadyLinked.title,
                    LocalizedStrings.FailurePendingContent.AlreadyLinked.subtitle)
        case .namesMismatched:
            return (LocalizedStrings.FailurePendingContent.AccountNamesMismatched.title,
                    LocalizedStrings.FailurePendingContent.AccountNamesMismatched.subtitle)
        case .unsuportedAccount:
            return (LocalizedStrings.FailurePendingContent.AccountUnsupported.title,
                    LocalizedStrings.FailurePendingContent.AccountUnsupported.subtitle)
        case .timeout:
            return (LocalizedStrings.FailurePendingContent.Timeout.title,
                    LocalizedStrings.FailurePendingContent.Timeout.subtitle)
        case .unknown:
            return (LocalizedStrings.FailurePendingContent.Generic.title,
                    LocalizedStrings.FailurePendingContent.Generic.subtitle)
        }
    }
}
