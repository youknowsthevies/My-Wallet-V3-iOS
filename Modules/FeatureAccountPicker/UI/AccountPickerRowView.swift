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

    // MARK: - Init

    static func with(
        badgeView: @escaping (AnyHashable) -> AnyView,
        iconView: @escaping (AnyHashable) -> AnyView,
        multiBadgeView: @escaping (AnyHashable) -> (AnyView)
    ) -> (Store<AccountPickerRow, AccountPickerRowAction>) -> Self {
        { store in
            Self(
                store: store,
                badgeView: badgeView,
                iconView: iconView,
                multiBadgeView: multiBadgeView
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
                        badgeView: badgeView(model.id)
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
                case .singleAccount(let model):
                    SingleAccountRow(
                        model: model,
                        badgeView: badgeView(model.id),
                        iconView: iconView(model.id),
                        multiBadgeView: multiBadgeView(model.id)
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
                        // Note the constant placeholder text is never displayed to the user,
                        // instead it is hidden and used for sizing the shimmering view
                        Text(model.fiatBalance.value ?? "Placeholder")
                            .textStyle(.heading)
                            .shimmer(enabled: model.fiatBalance.isLoading)
                    }
                    HStack {
                        Text(model.description)
                            .textStyle(.subheading)
                        Spacer()
                        // Note the constant placeholder text is never displayed to the user,
                        // instead it is hidden and used for sizing the shimmering view
                        Text(model.currencyCode.value ?? "Placeholder")
                            .textStyle(.subheading)
                            .shimmer(enabled: model.currencyCode.isLoading)
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

private struct SingleAccountRow: View {

    let model: AccountPickerRow.SingleAccount
    let badgeView: AnyView
    let iconView: AnyView
    let multiBadgeView: AnyView

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
                            // Note the constant placeholder text is never displayed to the user,
                            // instead it is hidden and used for sizing the shimmering view
                            Text(model.fiatBalance.value ?? "Loading")
                                .textStyle(.heading)
                                .shimmer(enabled: model.fiatBalance.isLoading)
                            Text(model.cryptoBalance.value ?? "Placeholder")
                                .textStyle(.subheading)
                                .shimmer(enabled: model.cryptoBalance.isLoading)
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

    static let accountGroupRow = AccountPickerRow.accountGroup(
        AccountPickerRow.AccountGroup(
            id: UUID(),
            title: "All Wallets",
            description: "Total Balance",
            fiatBalance: .loaded(next: "$2,302.39"),
            currencyCode: .loaded(next: "USD")
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

    static let singleAccountRow = AccountPickerRow.singleAccount(
        AccountPickerRow.SingleAccount(
            id: UUID(),
            title: "BTC Trading Wallet",
            description: "Bitcoin",
            fiatBalance: .loaded(next: "$2,302.39"),
            cryptoBalance: .loaded(next: "0.21204887 BTC")
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
                multiBadgeView: { _ in AnyView(EmptyView()) }
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
                multiBadgeView: { _ in AnyView(EmptyView()) }
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
                multiBadgeView: { _ in AnyView(EmptyView()) }
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("LinkedBankAccountRow")

            AccountPickerRowView(
                store: Store(
                    initialState: singleAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: environment
                ),
                badgeView: { _ in AnyView(EmptyView()) },
                iconView: { _ in AnyView(EmptyView()) },
                multiBadgeView: { _ in AnyView(EmptyView()) }
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("SingleAccountRow")
        }
    }
}
