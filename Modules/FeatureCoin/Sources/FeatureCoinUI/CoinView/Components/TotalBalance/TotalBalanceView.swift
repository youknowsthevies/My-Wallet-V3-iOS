// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import FeatureCoinDomain
import Localization
import MoneyKit
import SwiftUI

struct TotalBalanceView<Trailing: View>: View {

    private typealias Localization = LocalizationConstants.Coin.Accounts

    let currency: CryptoCurrency
    let accounts: [Account.Snapshot]
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        BalanceSectionHeader(
            header: Localization.totalBalance.interpolating(currency.displayCode),
            title: accounts.fiatBalance?.displayString ?? 6.of(".").joined(),
            subtitle: accounts.cryptoBalance?.displayString ?? 10.of(".").joined(),
            trailing: trailing
        )
        .if(accounts.isEmpty || accounts.fiatBalance == nil || accounts.cryptoBalance == nil) { view in
            view.redacted(reason: .placeholder)
        }
    }
}

// swiftlint:disable type_name
struct TotalBalanceView_PreviewProvider: PreviewProvider {

    static var previews: some View {
        TotalBalanceView(
            currency: .bitcoin,
            accounts: [],
            trailing: { EmptyView() }
        )
    }
}
