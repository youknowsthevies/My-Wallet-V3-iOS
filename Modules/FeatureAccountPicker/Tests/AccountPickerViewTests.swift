// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
@testable import FeatureAccountPickerUI
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class AccountPickerViewTests: XCTestCase {

    let allIdentifier = UUID()
    let btcWalletIdentifier = UUID()
    let btcTradingWalletIdentifier = UUID()
    let ethWalletIdentifier = UUID()
    let bchWalletIdentifier = UUID()
    let bchTradingWalletIdentifier = UUID()

    lazy var fiatBalances: [AnyHashable: String] = [
        allIdentifier: "$2,302.39",
        btcWalletIdentifier: "$2,302.39",
        btcTradingWalletIdentifier: "$10,093.13",
        ethWalletIdentifier: "$807.21",
        bchWalletIdentifier: "$807.21",
        bchTradingWalletIdentifier: "$40.30"
    ]

    lazy var currencyCodes: [AnyHashable: String] = [
        allIdentifier: "USD"
    ]

    lazy var cryptoBalances: [AnyHashable: String] = [
        btcWalletIdentifier: "0.21204887 BTC",
        btcTradingWalletIdentifier: "1.38294910 BTC",
        ethWalletIdentifier: "0.17039384 ETH",
        bchWalletIdentifier: "0.00388845 BCH",
        bchTradingWalletIdentifier: "0.00004829 BCH"
    ]

    lazy var accountPickerRowList: IdentifiedArrayOf<AccountPickerRow> = [
        .accountGroup(
            AccountPickerRow.AccountGroup(
                id: allIdentifier,
                title: "All Wallets",
                description: "Total Balance"
            )
        ),
        .button(
            AccountPickerRow.Button(
                id: UUID(),
                text: "See Balance"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: btcWalletIdentifier,
                title: "BTC Wallet",
                description: "Bitcoin"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: btcTradingWalletIdentifier,
                title: "BTC Trading Wallet",
                description: "Bitcoin"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: ethWalletIdentifier,
                title: "ETH Wallet",
                description: "Ethereum"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: bchWalletIdentifier,
                title: "BCH Wallet",
                description: "Bitcoin Cash"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: bchTradingWalletIdentifier,
                title: "BCH Trading Wallet",
                description: "Bitcoin Cash"
            )
        )
    ]

    let header = Header.normal(
        title: "Send Crypto Now",
        subtitle: "Choose a Wallet to send cypto from.",
        image: ImageAsset.iconSend.image,
        tableTitle: "Select a Wallet",
        searchable: false
    )

    func testView() {
        let view = AccountPickerView(
            store: Store(
                initialState: AccountPickerState(
                    rows: .loaded(next: .success(accountPickerRowList)),
                    header: header,
                    fiatBalances: fiatBalances,
                    cryptoBalances: cryptoBalances,
                    currencyCodes: currencyCodes
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment(
                    rowSelected: { _ in },
                    backButtonTapped: {},
                    closeButtonTapped: {},
                    search: { _ in },
                    sections: { .just([]).eraseToAnyPublisher() },
                    updateSingleAccount: { _ in nil },
                    updateAccountGroup: { _ in nil },
                    header: { [unowned self] in .just(header).eraseToAnyPublisher() }
                )
            ),
            badgeView: { _ in AnyView(EmptyView()) },
            iconView: { _ in AnyView(EmptyView()) },
            multiBadgeView: { _ in AnyView(EmptyView()) }
        )

        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone8)))
    }
}
