import Combine
import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI
import UIComponentsKit

public struct AccountPickerView: View {

    // MARK: - Internal properties

    let store: Store<AccountPickerState, AccountPickerAction>
    let badgeView: (AnyHashable) -> AnyView
    let iconView: (AnyHashable) -> AnyView
    let multiBadgeView: (AnyHashable) -> (AnyView)

    // MARK: - Init

    init(
        store: Store<AccountPickerState, AccountPickerAction>,
        badgeView: @escaping (AnyHashable) -> AnyView,
        iconView: @escaping (AnyHashable) -> AnyView,
        multiBadgeView: @escaping (AnyHashable) -> (AnyView)
    ) {
        self.store = store
        self.badgeView = badgeView
        self.iconView = iconView
        self.multiBadgeView = multiBadgeView
    }

    public init(
        environment: AccountPickerEnvironment,
        badgeView: @escaping (AnyHashable) -> AnyView,
        iconView: @escaping (AnyHashable) -> AnyView,
        multiBadgeView: @escaping (AnyHashable) -> (AnyView)
    ) {
        self.init(
            store: Store(
                initialState: AccountPickerState(
                    rows: [],
                    header: .simple(
                        AccountPickerState.HeaderModel(
                            title: "Swap",
                            subtitle: "Which wallet do you want to Swap from?"
                        )
                    )
                ),
                reducer: accountPickerReducer,
                environment: environment
            ),
            badgeView: badgeView,
            iconView: iconView,
            multiBadgeView: multiBadgeView
        )
    }

    // MARK: - Body

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: .zero) {
                if let header = viewStore.header {
                    AccountPickerViewHeader(header: header)
                        .padding()
                }
                Divider()
                List {
                    ForEachStore(
                        self.store.scope(
                            state: \.rows,
                            action: AccountPickerAction.accountPickerRow(id:action:)
                        ),
                        content: AccountPickerRowView.with(
                            badgeView: badgeView,
                            iconView: iconView,
                            multiBadgeView: multiBadgeView
                        )
                    )
                    .listRowInsets(EdgeInsets())
                }
            }
            .onAppear {
                viewStore.send(.subscribeToUpdates)
            }
        }
    }
}

private struct AccountPickerViewHeader: View {

    let header: AccountPickerState.Header

    var body: some View {
        switch header {
        case .standard(let model):
            VStack(alignment: .leading, spacing: 10) {
                Text(model.title)
                    .textStyle(.title)
                Text(model.subtitle)
                    .textStyle(.subheading)
                if let listTitle = model.listTitle {
                    Text(listTitle)
                        .font(.system(size: 12))
                }
            }
        case .simple(let model):
            VStack(alignment: .leading, spacing: .zero) {
                Text(model.title)
                    .textStyle(.title)
                Text(model.subtitle)
                    .textStyle(.subheading)
            }
        }
    }
}

struct AccountPickerView_Previews: PreviewProvider {

    static let accountPickerRowList: IdentifiedArrayOf<AccountPickerRow> = [
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

    static let standardHeader: AccountPickerState.Header = .standard(
        AccountPickerState.HeaderModel(
            title: "Swap Your Crypto",
            subtitle: "Instantly exchange your crypto into any currency we offer for your wallet",
            listTitle: "Trending"
        )
    )

    static let simpleHeader: AccountPickerState.Header = .simple(
        AccountPickerState.HeaderModel(
            title: "Swap",
            subtitle: "Which wallet do you want to Swap from?"
        )
    )

    static var previews: some View {
        AccountPickerView(
            store: Store(
                initialState: AccountPickerState(
                    rows: [],
                    header: simpleHeader
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment(
                    rowSelected: { _ in },
                    backButtonTapped: {},
                    closeButtonTapped: {},
                    sections: { Just(Array(accountPickerRowList)).eraseToAnyPublisher() },
                    updateSingleAccount: { _ in nil },
                    updateAccountGroup: { _ in nil }
                )
            ),
            badgeView: { _ in AnyView(EmptyView()) },
            iconView: { _ in AnyView(EmptyView()) },
            multiBadgeView: { _ in AnyView(EmptyView()) }
        )
    }
}
