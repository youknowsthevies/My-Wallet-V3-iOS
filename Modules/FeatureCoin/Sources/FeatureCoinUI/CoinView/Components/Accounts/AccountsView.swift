// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import Localization
import SwiftUI

public struct AccountsView: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let assetColor: Color
    let accounts: [Account]
    let apy: String

    public init(assetColor: Color, accounts: [Account], apy: String = "6.66") {
        self.assetColor = assetColor
        self.accounts = accounts
        self.apy = apy
    }

    private typealias Localization = LocalizationConstants.Coin.Accounts

    public var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: Localization.sectionTitle)

            ForEach(accounts) { account in
                AccountRow(
                    account: account,
                    assetColor: assetColor
                ) {}
                    .context([blockchain.ux.asset.account.id: account.id])

                PrimaryDivider()
            }

            if !accounts.contains(where: { account in
                account.accountType != .privateKey
            }) {
                LockedAccountRow(
                    title: Localization.tradingAccountTitle,
                    subtitle: Localization.tradingAccountSubtitle,
                    icon: .trade
                ) {}

                PrimaryDivider()

                LockedAccountRow(
                    title: Localization.rewardsAccountTitle,
                    subtitle: Localization.rewardsAccountSubtitle.interpolating(apy),
                    icon: .interestCircle
                ) {}

                PrimaryDivider()

                LockedAccountRow(
                    title: Localization.exchangeAccountTitle,
                    subtitle: Localization.exchangeAccountSubtitle,
                    icon: .walletExchange
                ) {}
                PrimaryDivider()
            }
        }
    }
}

// swiftlint:disable type_name
struct AccountsView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AccountsView(
                assetColor: .orange,
                accounts: [
                    Account(
                        id: "",
                        name: "My Bitcoin Wallet",
                        accountType: .privateKey,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        cryptoBalancePublisher: .empty(),
                        fiatBalancePublisher: .empty()
                    )
                ]
            )
        }
    }
}
