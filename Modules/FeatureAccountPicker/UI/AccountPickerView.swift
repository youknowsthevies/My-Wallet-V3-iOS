import Combine
import ComposableArchitecture
import FeatureAccountPickerDomain
import Localization
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
                    header: .none
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
                HeaderView(viewModel: viewStore.header)
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

struct AccountPickerView_Previews: PreviewProvider {

    static let accountPickerRowList: IdentifiedArrayOf<AccountPickerRow> = [
        .accountGroup(
            AccountPickerRow.AccountGroup(
                id: UUID(),
                title: "All Wallets",
                description: "Total Balance",
                fiatBalance: .loaded(next: "$2,302.39"),
                currencyCode: .loaded(next: "USD")
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
                fiatBalance: .loaded(next: "$2,302.39"),
                cryptoBalance: .loaded(next: "0.21204887 BTC")
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BTC Trading Wallet",
                description: "Bitcoin",
                fiatBalance: .loaded(next: "$10,093.13"),
                cryptoBalance: .loaded(next: "1.38294910 BTC")
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "ETH Wallet",
                description: "Ethereum",
                fiatBalance: .loaded(next: "$807.21"),
                cryptoBalance: .loaded(next: "0.17039384 ETH")
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BCH Wallet",
                description: "Bitcoin Cash",
                fiatBalance: .loaded(next: "$807.21"),
                cryptoBalance: .loaded(next: "0.00388845 BCH")
            )
        ),
        .singleAccount(
            AccountPickerRow.SingleAccount(
                id: UUID(),
                title: "BCH Trading Wallet",
                description: "Bitcoin Cash",
                fiatBalance: .loaded(next: "$40.30"),
                cryptoBalance: .loaded(next: "0.00004829 BCH")
            )
        )
    ]

    static let header = Header.normal(
        title: "Send Crypto Now",
        subtitle: "Choose a Wallet to send cypto from.",
        image: ImageAsset.iconSend.image,
        tableTitle: "Select a Wallet"
    )

    static var previews: some View {
        AccountPickerView(
            store: Store(
                initialState: AccountPickerState(
                    rows: [],
                    header: header
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment(
                    rowSelected: { _ in },
                    backButtonTapped: {},
                    closeButtonTapped: {},
                    sections: { Just(Array(accountPickerRowList)).eraseToAnyPublisher() },
                    updateSingleAccount: { _ in nil },
                    updateAccountGroup: { _ in nil },
                    header: { Just(header).setFailureType(to: Error.self).eraseToAnyPublisher() }
                )
            ),
            badgeView: { _ in AnyView(EmptyView()) },
            iconView: { _ in AnyView(EmptyView()) },
            multiBadgeView: { _ in AnyView(EmptyView()) }
        )
    }
}
