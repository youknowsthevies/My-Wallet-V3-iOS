// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import FeatureCoinDomain
import MoneyKit
import SwiftUI

struct TotalBalanceView<Trailing: View>: View {
    let assetDetails: AssetDetails
    let accounts: [Account]
    let trailing: Trailing

    var cryptoValuePublisher: AnyPublisher<MoneyValue, Never>
    @State private var cryptoValue: String = ""

    var fiatValuePublisher: AnyPublisher<MoneyValue, Never>
    @State private var fiatValue: String = ""

    init(
        assetDetails: AssetDetails,
        accounts: [Account],
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.assetDetails = assetDetails
        self.accounts = accounts
        self.trailing = trailing()
        cryptoValuePublisher = accounts.totalCryptoBalancePublisher
        fiatValuePublisher = accounts.totalFiatBalancePublisher
    }

    var body: some View {
        BalanceSectionHeader(
            header: "Your Total \(assetDetails.code)",
            title: fiatValue,
            subtitle: cryptoValue
        ) {
            trailing
        }
        .onReceive(cryptoValuePublisher) {
            cryptoValue = $0.displayString
        }
        .onReceive(fiatValuePublisher) {
            fiatValue = $0.displayString
        }
    }
}

// swiftlint:disable type_name
struct TotalBalanceView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        TotalBalanceView(
            assetDetails: .init(
                name: CoinView.PreviewHelper.name,
                code: CoinView.PreviewHelper.code,
                brandColor: .orange,
                about: CoinView.PreviewHelper.about,
                assetInfoUrl: CoinView.PreviewHelper.url,
                logoUrl: CoinView.PreviewHelper.logoResource,
                logoImage: nil,
                tradeable: true,
                onWatchlist: true
            ),
            accounts: [],
            trailing: {}
        )
    }
}
