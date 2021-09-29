// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
@testable import FeatureAccountPickerUI
import SnapshotTesting
import SwiftUI
import UIComponentsKit
import XCTest

class AccountPickerViewTests: XCTestCase {

    let accountPickerRowList: IdentifiedArrayOf<AccountPickerRow> = [
        .accountGroup(
            AccountPickerRow.AccountGroup(
                id: UUID(),
                title: "All Wallets",
                description: "Total Balance",
                fiatBalance: "$2,302.39",
                currencyCode: "USD"
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
                id: UUID(),
                title: "BTC Wallet",
                description: "Bitcoin",
                fiatBalance: "$2,302.39",
                cryptoBalance: "0.21204887 BTC"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BTC Trading Wallet",
                description: "Bitcoin",
                fiatBalance: "$10,093.13",
                cryptoBalance: "1.38294910 BTC"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "ETH Wallet",
                description: "Ethereum",
                fiatBalance: "$807.21",
                cryptoBalance: "0.17039384 ETH"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BCH Wallet",
                description: "Bitcoin Cash",
                fiatBalance: "$807.21",
                cryptoBalance: "0.00388845 BCH"
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BCH Trading Wallet",
                description: "Bitcoin Cash",
                fiatBalance: "$40.30",
                cryptoBalance: "0.00004829 BCH"
            )
        )
    ]

    let header = Header.normal(
        title: "Send Crypto Now",
        subtitle: "Choose a Wallet to send cypto from.",
        image: ImageAsset.iconSend.image,
        tableTitle: "Select a Wallet"
    )

    func testView() {
        let view = AccountPickerView(
            store: Store(
                initialState: AccountPickerState(
                    rows: accountPickerRowList,
                    header: header
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment(
                    rowSelected: { _ in },
                    backButtonTapped: {},
                    closeButtonTapped: {},
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
