import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
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

    // MARK: - Private properties

    @State private var isSearching: Bool = false

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
                    rows: .loading,
                    header: .none,
                    fiatBalances: [:],
                    cryptoBalances: [:],
                    currencyCodes: [:]
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

        WithViewStore(store) { viewStore in

            StatefulView(
                store: store.scope(state: \.rows),
                loadedAction: AccountPickerAction.rowsLoaded,
                loadingAction: AccountPickerAction.rowsLoading,
                successAction: LoadedRowsAction.success,
                failureAction: LoadedRowsAction.failure,
                loading: { _ in
                    LoadingStateView(title: LocalizationConstants.loading)
                },
                success: { store in
                    WithViewStore(store) { [globalViewStore = viewStore] viewStore in
                        if viewStore.state.isEmpty {
                            EmptyStateView(
                                title: LocalizationConstants.AccountPicker.noWallets,
                                subHeading: "",
                                image: ImageAsset.emptyActivity.image
                            )
                        } else {
                            contentView(
                                store: store,
                                viewStore: globalViewStore
                            )
                        }
                    }
                },
                failure: { _ in
                    ErrorStateView(title: LocalizationConstants.Errors.genericError)
                }
            )
            .onAppear {
                viewStore.send(.subscribeToUpdates)
            }
        }
    }

    @ViewBuilder func contentView(
        store: Store<IdentifiedArrayOf<AccountPickerRow>, SuccessRowsAction>,
        viewStore: ViewStore<AccountPickerState, AccountPickerAction>
    ) -> some View {
        VStack(spacing: .zero) {
            HeaderView(
                viewModel: viewStore.header,
                searchText: Binding<String?>(
                    get: { viewStore.searchText },
                    set: { viewStore.send(.search($0)) }
                ),
                isSearching: $isSearching
            )
            List {
                ForEachStore(
                    store.scope(
                        state: { $0 },
                        action: SuccessRowsAction.accountPickerRow(id:action:)
                    ),
                    content: AccountPickerRowView.with(
                        badgeView: badgeView,
                        iconView: iconView,
                        multiBadgeView: multiBadgeView,
                        fiatBalances: viewStore.fiatBalances,
                        cryptoBalances: viewStore.cryptoBalances,
                        currencyCodes: viewStore.currencyCodes
                    )
                )
                .listRowInsets(EdgeInsets())
            }
            .animation(.easeInOut, value: isSearching)
        }
    }
}

struct AccountPickerView_Previews: PreviewProvider {
    static let allIdentifier = UUID()
    static let btcWalletIdentifier = UUID()
    static let btcTradingWalletIdentifier = UUID()
    static let ethWalletIdentifier = UUID()
    static let bchWalletIdentifier = UUID()
    static let bchTradingWalletIdentifier = UUID()

    static let fiatBalances: [AnyHashable: String] = [
        allIdentifier: "$2,302.39",
        btcWalletIdentifier: "$2,302.39",
        btcTradingWalletIdentifier: "$10,093.13",
        ethWalletIdentifier: "$807.21",
        bchWalletIdentifier: "$807.21",
        bchTradingWalletIdentifier: "$40.30"
    ]

    static let currencyCodes: [AnyHashable: String] = [
        allIdentifier: "USD"
    ]

    static let cryptoBalances: [AnyHashable: String] = [
        btcWalletIdentifier: "0.21204887 BTC",
        btcTradingWalletIdentifier: "1.38294910 BTC",
        ethWalletIdentifier: "0.17039384 ETH",
        bchWalletIdentifier: "0.00388845 BCH",
        bchTradingWalletIdentifier: "0.00004829 BCH"
    ]

    static let accountPickerRowList: IdentifiedArrayOf<AccountPickerRow> = [
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

    static let header = Header.normal(
        title: "Send Crypto Now",
        subtitle: "Choose a Wallet to send cypto from.",
        image: ImageAsset.iconSend.image,
        tableTitle: "Select a Wallet",
        searchable: false
    )

    @ViewBuilder static func view(
        rows: LoadingState<Result<IdentifiedArrayOf<AccountPickerRow>, AccountPickerError>>
    ) -> AccountPickerView {
        AccountPickerView(
            store: Store(
                initialState: AccountPickerState(
                    rows: rows,
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

    static var previews: some View {
        view(rows: .loaded(next: .success(accountPickerRowList)))
            .previewDisplayName("Success")

        view(rows: .loaded(next: .success([])))
            .previewDisplayName("Empty")

        view(rows: .loaded(next: .failure(.testError)))
            .previewDisplayName("Error")

        view(rows: .loading)
            .previewDisplayName("Loading")
    }
}
