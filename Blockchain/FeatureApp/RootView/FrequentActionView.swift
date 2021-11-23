//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import Localization
import SwiftUI

struct FrequentAction: Hashable, Identifiable {
    var id: Self { self }
    let name: String
    let icon: Icon
    let description: String
}

extension FrequentAction {

    typealias Localization = LocalizationConstants.FrequentActionItem

    static let swap = FrequentAction(
        name: Localization.swap.name,
        icon: .walletSwap,
        description: Localization.swap.description
    )
    static let send = FrequentAction(
        name: Localization.send.name,
        icon: .walletSend,
        description: Localization.send.description
    )
    static let receive = FrequentAction(
        name: Localization.receive.name,
        icon: .walletReceive,
        description: Localization.receive.description
    )
    static let rewards = FrequentAction(
        name: Localization.rewards.name,
        icon: .walletPercent,
        description: Localization.rewards.description
    )
    static let deposit = FrequentAction(
        name: Localization.deposit.name,
        icon: .walletDeposit,
        description: Localization.deposit.description
    )
    static let withdraw = FrequentAction(
        name: Localization.withdraw.name,
        icon: .walletWithdraw,
        description: Localization.withdraw.description
    )
    static let buy = FrequentAction(
        name: Localization.buy,
        icon: .walletBuy,
        description: Localization.buy
    )
    static let sell = FrequentAction(
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
                        HStack {
                            item.icon.circle()
                                .accentColor(.semantic.primary)
                                .frame(width: 32.pt)
                                .padding(.trailing, 8.pt)
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .typography(.body2)
                                    .foregroundColor(.semantic.title)
                                Text(item.description)
                                    .typography(.paragraph1)
                                    .foregroundColor(.semantic.body)
                            }
                            .multilineTextAlignment(.leading)
                            Spacer()
                            Icon.chevronRight
                                .frame(width: 24.pt)
                                .accentColor(.semantic.muted)
                        }
                        .background(Color.semantic.background)
                        .padding([.leading, .trailing], 24.pt)
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .frame(width: .infinity)
                .frame(minHeight: 76.pt)
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
