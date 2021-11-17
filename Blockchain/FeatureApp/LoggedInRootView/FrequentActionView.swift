//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import Localization
import SwiftUI

struct FrequentAction: Hashable, Identifiable {
    var id: Self { self }
    let name: String
    let description: String
}

extension FrequentAction {

    typealias Localization = LocalizationConstants.FrequentActionItem

    static let swap = FrequentAction(
        name: Localization.swap.name,
        description: Localization.swap.description
    )
    static let send = FrequentAction(
        name: Localization.send.name,
        description: Localization.send.name
    )
    static let receive = FrequentAction(
        name: Localization.receive.name,
        description: Localization.receive.name
    )
    static let rewards = FrequentAction(
        name: Localization.rewards.name,
        description: Localization.rewards.name
    )
    static let deposit = FrequentAction(
        name: Localization.deposit.name,
        description: Localization.deposit.name
    )
    static let withdraw = FrequentAction(
        name: Localization.withdraw.name,
        description: Localization.withdraw.name
    )
    static let buy = FrequentAction(
        name: Localization.buy,
        description: Localization.buy
    )
    static let sell = FrequentAction(
        name: Localization.sell,
        description: Localization.sell
    )
}

struct FrequentActionView: View {

    private let list: [FrequentAction] = [
        .swap,
        .send,
        .receive,
        .rewards,
        .deposit,
        .withdraw
    ]

    private let buttons: [FrequentAction] = [
        .buy,
        .sell
    ]

    var action: (FrequentAction) -> Void

    var body: some View {
        ForEach(list.indexed(), id: \.element) { index, item in
            if index != list.startIndex {
                PrimaryDivider()
                    .padding(.leading)
            }
            Button(
                action: { action(item) },
                label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
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
                            .frame(width: 18.pt)
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
