// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct AccountRow: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    let assetColor: Color
    let interestRate: Double?

    var body: some View {
        BalanceRow(
            leadingTitle: account.name,
            leadingDescription: account.accountType.subtitle.interpolating(interestRate.or(0)),
            trailingTitle: account.fiat.displayString,
            trailingDescription: account.crypto.displayString,
            trailingDescriptionColor: .semantic.muted,
            action: {
                withAnimation(.spring()) {
                    app.post(
                        event: blockchain.ux.asset.account.sheet[].ref(to: context),
                        context: context + [
                            blockchain.ux.asset.account: account
                        ]
                    )
                }
            },
            leading: {
                account.accountType.icon
                    .accentColor(assetColor)
                    .frame(width: 24)
            }
        )
    }
}

extension Account.AccountType {

    private typealias Localization = LocalizationConstants.Coin.Account

    var icon: Icon {
        switch self {
        case .exchange:
            return .walletExchange
        case .interest:
            return .interestCircle
        case .privateKey:
            return .private
        case .trading:
            return .trade
        }
    }

    var subtitle: String {
        switch self {
        case .exchange:
            return Localization.exchange.subtitle
        case .interest:
            return Localization.interest.subtitle
        case .privateKey:
            return Localization.privateKey.subtitle
        case .trading:
            return Localization.trading.subtitle
        }
    }
}

// swiftlint:disable type_name
struct AccountRow_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 0) {
                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Private Key Wallet",
                        accountType: .privateKey,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD)
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Trading Account",
                        accountType: .trading,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD)
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Rewards Account",
                        accountType: .interest,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD)
                    ),
                    assetColor: .orange,
                    interestRate: 2.5
                )

                PrimaryDivider()

                AccountRow(
                    account: .init(
                        id: "",
                        name: "Exchange Account",
                        accountType: .exchange,
                        cryptoCurrency: .bitcoin,
                        fiatCurrency: .USD,
                        actions: [],
                        crypto: .one(currency: .bitcoin),
                        fiat: .one(currency: .USD)
                    ),
                    assetColor: .orange,
                    interestRate: nil
                )

                PrimaryDivider()
            }
        }
    }
}
