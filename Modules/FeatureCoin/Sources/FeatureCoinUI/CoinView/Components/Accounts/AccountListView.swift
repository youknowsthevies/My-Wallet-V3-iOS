// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import SwiftUI

public struct AccountListView: View {

    private typealias Localization = LocalizationConstants.Coin.Accounts

    @BlockchainApp var app
    @Environment(\.context) var context

    let accounts: [Account.Snapshot]

    let assetColor: Color
    let interestRate: Double?

    public var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: Localization.sectionTitle)
            if accounts.isEmpty {
                locked()
                    .redacted(reason: .placeholder)
                    .disabled(true)
            } else {
                ForEach(accounts) { account in
                    AccountRow(
                        account: account,
                        assetColor: assetColor,
                        interestRate: interestRate
                    )
                    .context([blockchain.ux.asset.account.id: account.id])
                    PrimaryDivider()
                }
                if !accounts.contains(where: { account in account.accountType != .privateKey }) {
                    locked()
                }
            }
        }
    }

    @ViewBuilder func locked() -> some View {
        LockedAccountRow(
            title: Localization.tradingAccountTitle,
            subtitle: Localization.tradingAccountSubtitle,
            icon: .trade
        )
        PrimaryDivider()
        LockedAccountRow(
            title: Localization.rewardsAccountTitle,
            subtitle: Localization.rewardsAccountSubtitle.interpolating(interestRate.or(0)),
            icon: .interestCircle
        )
        PrimaryDivider()
        LockedAccountRow(
            title: Localization.exchangeAccountTitle,
            subtitle: Localization.exchangeAccountSubtitle,
            icon: .walletExchange
        )
        PrimaryDivider()
    }
}

// swiftlint:disable type_name
struct AccountListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AccountListView(
                accounts: [
                    Account.Snapshot(
                        id: "",
                        name: "My Bitcoin Wallet",
                        accountType: .privateKey,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .zero(currency: .bitcoin),
                        fiat: .zero(currency: .GBP)
                    )
                ],
                assetColor: .orange,
                interestRate: nil
            )
        }
    }
}
