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
    let kycStatus: KYCStatus

    var __accounts: [Account.Snapshot] {
        switch kycStatus {
        case .unverified, .inReview:
            return accounts.filter(\.isPrivateKey)
        case .silver, .silverPlus, .gold:
            return accounts
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: Localization.sectionTitle)
            if accounts.isEmpty {
                loading()
            } else {
                ForEach(__accounts) { account in
                    AccountRow(
                        account: account,
                        assetColor: assetColor,
                        interestRate: interestRate
                    )
                    .context([blockchain.ux.asset.account.id: account.id])
                    PrimaryDivider()
                }
                switch kycStatus {
                case .unverified, .inReview:
                    locked()
                case .silver, .silverPlus, .gold:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder func loading() -> some View {
        Group {
            ForEach(1...3, id: \.self) { _ in
                LockedAccountRow(
                    title: Localization.tradingAccountTitle,
                    subtitle: Localization.tradingAccountSubtitle,
                    icon: .trade
                )
                PrimaryDivider()
            }
        }
        .disabled(true)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder func locked() -> some View {
        LockedAccountRow(
            title: Localization.tradingAccountTitle,
            subtitle: Localization.tradingAccountSubtitle,
            icon: .trade
        )
        .context([blockchain.ux.asset.account.type: Account.AccountType.trading])
        PrimaryDivider()
        LockedAccountRow(
            title: Localization.rewardsAccountTitle,
            subtitle: Localization.rewardsAccountSubtitle.interpolating(interestRate.or(0)),
            icon: .interestCircle
        )
        .context([blockchain.ux.asset.account.type: Account.AccountType.interest])
        PrimaryDivider()
    }
}

// swiftlint:disable type_name
struct AccountListView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            assetColor: .orange,
            interestRate: nil,
            kycStatus: .gold
        )
        .previewDisplayName("Gold")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            assetColor: .orange,
            interestRate: nil,
            kycStatus: .silver
        )
        .previewDisplayName("Silver")
        AccountListView(
            accounts: [
                .preview.privateKey,
                .preview.trading,
                .preview.rewards
            ],
            assetColor: .orange,
            interestRate: nil,
            kycStatus: .unverified
        )
        .previewDisplayName("Unverified")
    }
}

extension Account.Snapshot {
    var isPrivateKey: Bool { accountType == .privateKey }
}
