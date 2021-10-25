// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import OpenBanking
import ToolKit
import UIComponentsKit

extension BankState.UI {

    static func communicating(to institution: String) -> Self {
        Self(
            info: .init(
                media: .blockchainLogo,
                overlay: .init(progress: true),
                title: Localization.Bank.Communicating.title.interpolating(institution),
                subtitle: Localization.Bank.Communicating.subtitle
            ),
            action: [.retry(label: Localization.Bank.Action.retry, action: .request)]
        )
    }

    static func waiting(for institution: String) -> Self {
        Self(
            info: .init(
                media: .blockchainLogo,
                overlay: .init(progress: true),
                title: Localization.Bank.Waiting.title.interpolating(institution),
                subtitle: Localization.Bank.Waiting.subtitle
            ),
            action: [.retry(label: Localization.Bank.Action.retry, action: .request)]
        )
    }

    static let updatingWallet: Self = .init(
        info: .init(
            media: .blockchainLogo,
            overlay: .init(progress: true),
            title: Localization.Bank.Updating.title,
            subtitle: Localization.Bank.Updating.subtitle
        ),
        action: .none
    )

    static func linked(institution: String) -> Self {
        Self(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .success),
                title: Localization.Bank.Linked.title,
                subtitle: Localization.Bank.Linked.subtitle.interpolating(institution)
            ),
            action: [.next]
        )
    }

    private static var formatter = (
        iso8601: ISO8601DateFormatter(),
        date: with(DateFormatter()) { formatter in
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        }
    )

    static func payment(success payment: OpenBanking.Payment.Details, in environment: OpenBankingEnvironment) -> Self {

        guard let fiat = environment.fiatCurrencyFormatter.displayString(
            amountMinor: payment.amount.value,
            currency: payment.amount.symbol
        ) else {
            return .errorMessage(Localization.Bank.Payment.error.interpolating(payment.amount.symbol))
        }

        var formatted = (
            amount: fiat,
            currency: payment.amount.symbol,
            date: ""
        )

        if let date = formatter.iso8601.date(from: payment.insertedAt) {
            formatted.date = formatter.date.string(from: date)
        }

        return Self(
            info: .init(
                media: .bankIcon,
                overlay: .init(media: .success),
                title: Localization.Bank.Payment.title.interpolating(formatted.amount),
                subtitle: Localization.Bank.Payment.subtitle.interpolating(formatted.amount, formatted.currency, formatted.date)
            ),
            action: [.ok]
        )
    }
}
