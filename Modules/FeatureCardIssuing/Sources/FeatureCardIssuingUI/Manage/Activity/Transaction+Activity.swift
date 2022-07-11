// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BlockchainComponentLibrary
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

extension Card.Transaction {

    var displayDateTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd/MM")
        return dateFormatter.string(from: userTransactionTime)
    }

    var displayStatus: String {
        let localized = LocalizationConstants.CardIssuing.Manage.Transaction.Status.self
        switch state {
        case .pending:
            return localized.pending
        case .cancelled:
            return localized.cancelled
        case .declined:
            return localized.declined
        case .completed:
            return localized.completed
        }
    }

    var statusColor: Color {
        switch state {
        case .pending:
            return .WalletSemantic.muted
        case .cancelled:
            return .WalletSemantic.muted
        case .declined:
            return .WalletSemantic.error
        case .completed:
            return .WalletSemantic.success
        }
    }

    var icon: Icon {
        switch state {
        case .pending:
            return Icon.pending
        case .cancelled:
            return Icon.error
        case .declined:
            return Icon.error
        case .completed:
            return Icon.creditcard
        }
    }

    var tag: TagView {
        switch state {
        case .pending:
            return TagView(text: displayStatus, variant: .infoAlt)
        case .cancelled:
            return TagView(text: displayStatus, variant: .default)
        case .declined:
            return TagView(text: displayStatus, variant: .error)
        case .completed:
            return TagView(text: displayStatus, variant: .success)
        }
    }
}

extension FeatureCardIssuingDomain.Money {

    var displayString: String {
        guard let currency = try? CurrencyType(code: symbol),
              let decimal = Decimal(string: value)
        else {
            return ""
        }

        return MoneyValue.create(major: decimal, currency: currency).displayString
    }
}
