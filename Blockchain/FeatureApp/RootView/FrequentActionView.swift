//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import Localization
import SwiftUI

struct FrequentAction: Hashable, Identifiable {
    var id: Tag { tag }
    let tag: Tag
    let name: String
    let icon: Icon
    let description: String
}

extension FrequentAction {

    typealias Localization = LocalizationConstants.FrequentActionItem

    static let swap = FrequentAction(
        tag: blockchain.ux.user.fab.swap,
        name: Localization.swap.name,
        icon: .walletSwap,
        description: Localization.swap.description
    )
    static let send = FrequentAction(
        tag: blockchain.ux.user.fab.send,
        name: Localization.send.name,
        icon: .walletSend,
        description: Localization.send.description
    )
    static let receive = FrequentAction(
        tag: blockchain.ux.user.fab.receive,
        name: Localization.receive.name,
        icon: .walletReceive,
        description: Localization.receive.description
    )
    static let rewards = FrequentAction(
        tag: blockchain.ux.user.fab.rewards,
        name: Localization.rewards.name,
        icon: .walletPercent,
        description: Localization.rewards.description
    )
    static let deposit = FrequentAction(
        tag: blockchain.ux.user.fab.deposit,
        name: Localization.deposit.name,
        icon: .walletDeposit,
        description: Localization.deposit.description
    )
    static let withdraw = FrequentAction(
        tag: blockchain.ux.user.fab.withdraw,
        name: Localization.withdraw.name,
        icon: .walletWithdraw,
        description: Localization.withdraw.description
    )
    static let buy = FrequentAction(
        tag: blockchain.ux.user.fab.buy,
        name: Localization.buy,
        icon: .walletBuy,
        description: Localization.buy
    )
    static let sell = FrequentAction(
        tag: blockchain.ux.user.fab.sell,
        name: Localization.sell,
        icon: .walletSell,
        description: Localization.sell
    )
}

struct FrequentActionView: View {

    private let list: [FrequentAction] = [
        .swap,
        .send,
        .receive,
        .rewards
    ]

    private let buttons: [FrequentAction] = [
        .buy,
        .sell
    ]

    var action: (FrequentAction) -> Void

    var body: some View {
        ForEach(list.indexed(), id: \.element) { index, item in
            VStack(alignment: .leading, spacing: 0) {
                if index != list.startIndex {
                    PrimaryDivider()
                        .padding(.leading, 72.pt)
                }
                Button(
                    action: { action(item) },
                    label: {
                        PrimaryRow(
                            title: item.name,
                            subtitle: item.description,
                            leading: {
                                item.icon.circle()
                                    .accentColor(.semantic.primary)
                                    .frame(width: 32.pt)
                            }
                        )
                    }
                )
                .identity(item.tag)
                .buttonStyle(PlainButtonStyle())
            }
        }
        HStack {
            ForEach(buttons.indexed(), id: \.element) { index, button in
                switch index {
                case buttons.startIndex:
                    PrimaryButton(
                        title: button.name,
                        action: { action(button) }
                    )
                default:
                    SecondaryButton(
                        title: button.name,
                        action: { action(button) }
                    )
                }
            }
        }
        .padding()
    }
}
