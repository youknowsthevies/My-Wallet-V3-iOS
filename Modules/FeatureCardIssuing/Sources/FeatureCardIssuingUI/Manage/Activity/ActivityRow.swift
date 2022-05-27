// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCardIssuingDomain
import Localization
import SceneKit
import SwiftUI
import ToolKit

struct ActivityRow: View {

    let merchant: String
    let amount: String
    let status: String
    let date: String
    let statusColor: Color
    let icon: Icon
    let action: () -> Void

    init(
        merchant: String,
        amount: String,
        status: String,
        date: String,
        statusColor: Color,
        icon: Icon,
        action: @escaping () -> Void
    ) {
        self.merchant = merchant
        self.amount = amount
        self.status = status
        self.date = date
        self.statusColor = statusColor
        self.icon = icon
        self.action = action
    }

    var body: some View {
        PrimaryRow(
            title: merchant,
            subtitle: date,
            leading: {
                icon
                    .frame(width: 20, height: 20)
                    .accentColor(.WalletSemantic.muted)
            },
            trailing: {
                VStack(alignment: .trailing, spacing: 5) {
                    Text(amount)
                        .typography(.body2)
                        .foregroundColor(.WalletSemantic.title)

                    Text(status)
                        .typography(.paragraph1)
                        .foregroundColor(
                            statusColor
                        )
                }
            },
            action: action
        )
    }
}

extension ActivityRow {

    init(_ transaction: CardTransaction, action: @escaping () -> Void) {
        merchant = transaction.merchantName
        amount = transaction.displayAmount
        status = transaction.displayStatus
        date = transaction.displayDate
        statusColor = transaction.statusColor
        icon = transaction.icon
        self.action = action
    }
}

#if DEBUG

extension CardTransaction {

    static var success = CardTransaction(
        id: "42",
        value: Money(
            value: "40000",
            symbol: "BTC"
        ),
        date: Date(),
        status: .settled,
        merchantName: "Blockchain.com"
    )

    static var pending = CardTransaction(
        id: "43",
        value: Money(
            value: "42000",
            symbol: "BTC"
        ),
        date: Date(),
        status: .pending,
        merchantName: "Blockchain.com"
    )

    static var failed = CardTransaction(
        id: "44",
        value: Money(
            value: "41000",
            symbol: "BTC"
        ),
        date: Date(),
        status: .failed,
        merchantName: "Blockchain.com"
    )
}

struct ActivityRow_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ActivityRow(CardTransaction.success) {}
                    PrimaryDivider()
                    ActivityRow(CardTransaction.pending) {}
                    PrimaryDivider()
                    ActivityRow(CardTransaction.failed) {}
                    PrimaryDivider()
                }
            }
        }
    }
}
#endif
