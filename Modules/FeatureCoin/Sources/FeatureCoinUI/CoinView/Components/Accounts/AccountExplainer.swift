// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Collections
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI
import ToolKit

struct AccountExplainer: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    let interestRate: Double?
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .trailing) {
            IconButton(icon: Icon.closev2.circle(), action: onClose)
                .frame(width: 24.pt, height: 24.pt)
                .padding(.trailing, 8.pt)
            VStack(alignment: .center, spacing: 20) {
                let explainer = account.accountType.explainer(interestRate)
                account.accountType.icon
                    .frame(width: 48.pt, height: 48.pt)
                    .accentColor(.semantic.primary)
                VStack(spacing: 8) {
                    Text(explainer.title)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)
                    Text(explainer.body)
                        .multilineTextAlignment(.center)
                        .typography(.paragraph1)
                        .foregroundColor(.semantic.body)
                }
                PrimaryButton(title: explainer.action) {
                    withAnimation(.spring()) {
                        app.post(
                            event: blockchain.ux.asset.account.explainer.accept[].ref(to: context),
                            context: context + [
                                blockchain.ux.asset.account: account
                            ]
                        )
                    }
                }
            }
        }
        .padding([.leading, .trailing], Spacing.padding2)
        .padding(.bottom, 20.pt)
    }
}

extension Account.AccountType {

    struct Explainer {
        let title: String
        let body: String
        let action: String
    }

    func explainer(_ interestRate: Double?) -> Explainer {
        switch self {
        case .trading:
            return .trading
        case .interest:
            return .rewards(interestRate)
        case .privateKey:
            return .privateKey
        case .exchange:
            return .exchange
        }
    }
}

extension Account.AccountType.Explainer {

    private typealias Localization = LocalizationConstants.Coin.Account.Explainer

    static let privateKey = Self(
        title: Localization.privateKey.title,
        body: Localization.privateKey.body,
        action: Localization.privateKey.action
    )

    static let trading = Self(
        title: Localization.trading.title,
        body: Localization.trading.body,
        action: Localization.trading.action
    )

    static func rewards(_ interestRate: Double?) -> Self {
        Self(
            title: Localization.rewards.title,
            body: Localization.rewards.body.interpolating(interestRate ?? 0),
            action: Localization.rewards.action
        )
    }

    static let exchange = Self(
        title: Localization.exchange.title,
        body: Localization.exchange.body,
        action: Localization.exchange.action
    )
}

// swiftlint:disable type_name
struct AccountExplainer_PreviewProvider: PreviewProvider {

    static var previews: some View {
        AccountExplainer(account: .preview.privateKey, interestRate: nil, onClose: {})
        AccountExplainer(account: .preview.trading, interestRate: nil, onClose: {})
        AccountExplainer(account: .preview.rewards, interestRate: 2, onClose: {})
    }
}
