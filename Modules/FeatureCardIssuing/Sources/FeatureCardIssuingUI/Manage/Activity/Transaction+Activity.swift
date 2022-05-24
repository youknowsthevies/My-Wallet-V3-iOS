// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

extension CardTransaction {

    var displayDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    var displayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }

    var displayDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

    var displayAmount: String {
        guard let currency = try? CurrencyType(code: value.symbol),
              let amount = BigInt(value.value)
        else {
            return ""
        }

        let money = MoneyValue(amount: amount, currency: currency)
        return money.displayString
    }

    var displayStatus: String {
        let localized = LocalizationConstants.CardIssuing.Manage.Transaction.Status.self
        switch status {
        case .pending:
            return localized.pending
        case .settled:
            return localized.settled
        case .failed:
            return localized.failed
        }
    }

    var statusColor: Color {
        switch status {
        case .pending:
            return .WalletSemantic.muted
        case .failed:
            return .WalletSemantic.error
        case .settled:
            return .WalletSemantic.success
        }
    }

    var icon: Icon {
        switch status {
        case .pending:
            return Icon.pending
        case .failed:
            return Icon.error
        case .settled:
            return Icon.creditcard
        }
    }
}
