// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct TotalBalanceView<Trailing: View>: View {

    private typealias Localization = LocalizationConstants.Coin.Accounts

    let asset: AssetDetails
    let accounts: [Account.Snapshot]
    let trailing: () -> Trailing

    var body: some View {
        BalanceSectionHeader(
            header: Localization.totalBalance.interpolating(asset.code),
            title: accounts.fiatBalance?.displayString ?? 6.of(".").joined(),
            subtitle: accounts.cryptoBalance?.displayString ?? 10.of(".").joined(),
            trailing: trailing
        )
        .if(accounts.isEmpty || accounts.fiatBalance == nil || accounts.cryptoBalance == nil) { view in
            view.redacted(reason: .placeholder)
        }
    }
}

extension TotalBalanceView where Trailing == EmptyView {

    init(
        asset: AssetDetails,
        accounts: [Account.Snapshot]
    ) {
        self.init(asset: asset, accounts: accounts, trailing: EmptyView.init)
    }
}

// swiftlint:disable type_name
struct TotalBalanceView_PreviewProvider: PreviewProvider {

    static var previews: some View {
        TotalBalanceView(
            asset: .preview(),
            accounts: []
        )
    }
}
