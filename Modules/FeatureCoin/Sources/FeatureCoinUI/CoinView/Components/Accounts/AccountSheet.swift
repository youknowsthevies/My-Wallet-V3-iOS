// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureCoinDomain
import MoneyKit
import SwiftUI
import ToolKit

struct AccountSheet: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    let onClose: () -> Void

    var actions: [Account.Action] {
        account.actions
            .union(account.importantActions)
            .intersection(account.allowedActions)
            .sorted(like: account.allowedActions)
    }

    var maxHeight: Length {
        (85 / actions.count).clamped(to: 6..<11).vh
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                account.accountType.icon
                    .accentColor(account.color)
                    .frame(maxHeight: 24.pt)
                Text(account.name)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: Icon.closev2.circle(), action: onClose)
                    .frame(width: 24.pt, height: 24.pt)
                    .padding(.trailing, 8.pt)
            }
            .padding([.leading, .trailing])
            BalanceSectionHeader(
                title: account.fiat.displayString,
                subtitle: account.crypto.displayString
            )
            ForEach(actions) { action in
                PrimaryDivider()
                PrimaryRow(
                    title: action.title,
                    subtitle: action.description.interpolating(account.cryptoCurrency.code),
                    leading: {
                        action.icon.circle()
                            .accentColor(account.color)
                            .frame(maxHeight: 24.pt)
                    },
                    action: {
                        app.post(event: action.id[].ref(to: context))
                    }
                )
                .accessibility(identifier: action.id(\.id))
                .frame(maxHeight: maxHeight)
            }
        }
    }
}

extension Account.Snapshot {

    var color: Color {
        cryptoCurrency.color ?? .black
    }

    var allowedActions: [Account.Action] {
        switch accountType {
        case .interest:
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary, .activity]
        case .privateKey:
            return [.send, .receive, .swap, .sell, .activity]
        case .trading:
            return [.buy, .sell, .swap, .send, .receive, .activity]
        case .exchange:
            return [.exchange.withdraw, .exchange.deposit]
        }
    }

    var importantActions: [Account.Action] {
        switch accountType {
        case .interest:
            return [.rewards.withdraw, .rewards.deposit, .rewards.summary]
        default:
            return []
        }
    }
}

extension CryptoCurrency {

    var color: Color? {
        assetModel.spotColor.map(Color.init(hex:))
    }
}
