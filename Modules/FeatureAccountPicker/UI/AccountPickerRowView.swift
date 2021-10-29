// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAccountPickerDomain
import Localization
import SwiftUI
import UIComponentsKit

struct AccountPickerRowView: View {

    // MARK: - Internal properties

    let store: Store<AccountPickerRow, AccountPickerRowAction>
    let badgeView: (AnyHashable) -> AnyView
    let iconView: (AnyHashable) -> AnyView
    let multiBadgeView: (AnyHashable) -> (AnyView)
    let fiatBalances: [AnyHashable: String]
    let cryptoBalances: [AnyHashable: String]
    let currencyCodes: [AnyHashable: String]

    // MARK: - Init

    // swiftlint:disable:next function_parameter_count
    static func with(
        badgeView: @escaping (AnyHashable) -> AnyView,
        iconView: @escaping (AnyHashable) -> AnyView,
        multiBadgeView: @escaping (AnyHashable) -> (AnyView),
        fiatBalances: [AnyHashable: String],
        cryptoBalances: [AnyHashable: String],
        currencyCodes: [AnyHashable: String]
    ) -> (Store<AccountPickerRow, AccountPickerRowAction>) -> Self {
        { store in
            Self(
                store: store,
                badgeView: badgeView,
                iconView: iconView,
                multiBadgeView: multiBadgeView,
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
        }
    }

    // MARK: - Body

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.viewPrimaryBackground)
                    .contentShape(Rectangle())
                switch viewStore.state {
                case .label(let model):
                    Text(model.text)
                case .accountGroup(let model):
                    AccountGroupRow(
                        model: model,
                        badgeView: badgeView(model.id),
                        fiatBalance: fiatBalances[model.id],
                        currencyCode: currencyCodes[model.id]
                    )
                    .onAppear {
                        viewStore.send(.accountGroup(action: .subscribeToUpdates))
                    }
                case .button(let model):
                    ButtonRow(model: model) {
                        viewStore.send(.accountPickerRowDidTap)
                    }
                case .linkedBankAccount(let model):
                    LinkedBankAccountRow(
                        model: model,
                        badgeView: badgeView(model.id),
                        multiBadgeView: multiBadgeView(model.id)
                    )
                case .paymentMethodAccount(let model):
                    PaymentMethodRow(
                        model: model
                    )
                case .singleAccount(let model):
                    SingleAccountRow(
                        model: model,
                        badgeView: badgeView(model.id),
                        iconView: iconView(model.id),
                        multiBadgeView: multiBadgeView(model.id),
                        fiatBalance: fiatBalances[model.id],
                        cryptoBalance: cryptoBalances[model.id]
                    )
                    .onAppear {
                        viewStore.send(.singleAccount(action: .subscribeToUpdates))
                    }
                }
            }
            .onTapGesture {
                viewStore.send(.accountPickerRowDidTap)
            }
        }
    }
}

// MARK: - Specific Rows

private struct AccountGroupRow: View {

    let model: AccountPickerRow.AccountGroup
    let badgeView: AnyView
    let fiatBalance: String?
    let currencyCode: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 16) {
                badgeView
                    .frame(width: 32, height: 32)
                    .padding(6)
                VStack {
                    HStack {
                        Text(model.title)
                            .textStyle(.heading)
                        Spacer()
                        Text(fiatBalance ?? " ")
                            .textStyle(.heading)
                            .shimmer(
                                enabled: fiatBalance == nil,
                                width: 90
                            )
                    }
                    HStack {
                        Text(model.description)
                            .textStyle(.subheading)
                        Spacer()
                        Text(currencyCode ?? " ")
                            .textStyle(.subheading)
                            .shimmer(
                                enabled: currencyCode == nil,
                                width: 100
                            )
                    }
                }
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.lightBorder))
        }
    }
}

private struct ButtonRow: View {

    let model: AccountPickerRow.Button
    let action: () -> Void

    var body: some View {
        VStack {
            SecondaryButton(title: model.text) {
                action()
            }
            .frame(height: 48)
        }
        .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
    }
}

private struct LinkedBankAccountRow: View {

    let model: AccountPickerRow.LinkedBankAccount
    let badgeView: AnyView
    let multiBadgeView: AnyView

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    badgeView
                        .frame(width: 32, height: 32)
                        .padding(6)
                    Spacer()
                        .frame(width: 16)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.title)
                                .textStyle(.heading)
                            Text(model.description)
                                .textStyle(.subheading)
                        }
                    }
                }

                multiBadgeView
                    .padding(.top, 8)
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.lightBorder))
        }
    }
}

private struct PaymentMethodRow: View {

    let model: AccountPickerRow.PaymentMethod

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    ZStack {
                        model.badgeView
                            .frame(width: 32, height: 32)
                            .scaledToFit()
                    }
                    .frame(width: 32, height: 32)
                    .padding(6)
                    .background(model.badgeBackground)
                    .clipShape(Circle())

                    Spacer()
                        .frame(width: 16)

                    VStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(model.title)
                                .textStyle(.heading)
                            Text(model.description)
                                .textStyle(.subheading)
                        }
                    }
                    .offset(x: 0, y: -2) // visually align due to font padding
                }
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.lightBorder))
        }
    }
}

private struct SingleAccountRow: View {

    let model: AccountPickerRow.SingleAccount
    let badgeView: AnyView
    let iconView: AnyView
    let multiBadgeView: AnyView
    let fiatBalance: String?
    let cryptoBalance: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ZStack(alignment: .bottomTrailing) {
                        Group {
                            badgeView
                                .frame(width: 32, height: 32)
                        }
                        .padding(6)

                        iconView
                            .frame(width: 16, height: 16)
                    }
                    Spacer()
                        .frame(width: 16)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.title)
                                .textStyle(.heading)
                            Text(model.description)
                                .textStyle(.subheading)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(fiatBalance ?? " ")
                                .textStyle(.heading)
                                .shimmer(
                                    enabled: fiatBalance == nil,
                                    width: 90
                                )
                            Text(cryptoBalance ?? "")
                                .textStyle(.subheading)
                                .shimmer(
                                    enabled: cryptoBalance == nil,
                                    width: 100
                                )
                        }
                    }
                }

                multiBadgeView
            }
            .padding(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 24))

            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(UIColor.lightBorder))
        }
    }
}

struct AccountPickerRowView_Previews: PreviewProvider {

    static let accountGroupIdentifier = UUID()
    static let singleAccountIdentifier = UUID()

    static let fiatBalances: [AnyHashable: String] = [
        accountGroupIdentifier: "$2,302.39",
        singleAccountIdentifier: "$2,302.39"
    ]

    static let currencyCodes: [AnyHashable: String] = [
        accountGroupIdentifier: "USD"
    ]

    static let cryptoBalances: [AnyHashable: String] = [
        accountGroupIdentifier: "0.21204887 BTC",
        singleAccountIdentifier: "0.21204887 BTC"
    ]

    static let accountGroupRow = AccountPickerRow.accountGroup(
        AccountPickerRow.AccountGroup(
            id: UUID(),
            title: "All Wallets",
            description: "Total Balance"
        )
    )

    static let buttonRow = AccountPickerRow.button(
        AccountPickerRow.Button(
            id: UUID(),
            text: "See Balance"
        )
    )

    static let linkedBankAccountRow = AccountPickerRow.linkedBankAccount(
        AccountPickerRow.LinkedBankAccount(
            id: UUID(),
            title: "BTC",
            description: "5243424"
        )
    )

    static let paymentMethodAccountRow = AccountPickerRow.paymentMethodAccount(
        AccountPickerRow.PaymentMethod(
            id: UUID(),
            title: "Visa •••• 0000",
            description: "$1,200",
            badgeView: Image(systemName: "creditcard"),
            badgeBackground: .badgeBackgroundInfo
        )
    )

    static let singleAccountRow = AccountPickerRow.singleAccount(
        AccountPickerRow.SingleAccount(
            id: UUID(),
            title: "BTC Trading Wallet",
            description: "Bitcoin"
        )
    )

    static let environment = AccountPickerRowEnvironment(
        mainQueue: .main,
        updateSingleAccount: { _ in nil },
        updateAccountGroup: { _ in nil }
    )

    static var previews: some View {
        Group {
            AccountPickerRowView(
                store: Store(
                    initialState: accountGroupRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) },
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("AccountGroupRow")

            AccountPickerRowView(
                store: Store(
                    initialState: buttonRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) },
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("ButtonRow")

            AccountPickerRowView(
                store: Store(
                    initialState: linkedBankAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) },
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("LinkedBankAccountRow")

            AccountPickerRowView(
                store: Store(
                    initialState: paymentMethodAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) },
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("PaymentMethodAccountRow")

            AccountPickerRowView(
                store: Store(
                    initialState: singleAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) },
                fiatBalances: fiatBalances,
                cryptoBalances: cryptoBalances,
                currencyCodes: currencyCodes
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("SingleAccountRow")
        }
    }
}
