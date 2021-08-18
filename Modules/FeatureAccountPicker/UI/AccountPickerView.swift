import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI
import UIComponentsKit

public struct AccountPickerView: View {

    let store: Store<AccountPickerState, AccountPickerAction>

    init(store: Store<AccountPickerState, AccountPickerAction>) {
        self.store = store
    }

    public init() {
        self.init(
            store: Store(
                initialState: AccountPickerState(
                    rows: AccountPickerView_Previews.accountPickerRowList,
                    header: AccountPickerView_Previews.simpleHeader
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment()
            )
        )
    }

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
                        content: AccountPickerRowView.init(store:)
                    )
                }
                .padding()
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
        AccountPickerRow.AccountGroupRowMockFactory.makeRow(
            name: "BTC Wallet",
            description: "Bitcoin",
            formattedQuote: "$2,302.39",
            formattedPriceChange: "0.21204887 BTC"
        ),
        AccountPickerRow.AccountGroupRowMockFactory.makeRow(
            name: "BTC Trading Wallet",
            description: "Bitcoin",
            formattedQuote: "$10,093.13",
            formattedPriceChange: "1.38294910 BTC"
        ),
        AccountPickerRow.AccountGroupRowMockFactory.makeRow(
            name: "ETH Wallet",
            description: "Ethereum",
            formattedQuote: "$807.21",
            formattedPriceChange: "0.17039384 ETH"
        ),
        AccountPickerRow.AccountGroupRowMockFactory.makeRow(
            name: "BCH Wallet",
            description: "Bitcoin Cash",
            formattedQuote: "$807.21",
            formattedPriceChange: "0.00388845 BCH"
        ),
        AccountPickerRow.AccountGroupRowMockFactory.makeRow(
            name: "BCH Trading Wallet",
            description: "Bitcoin Cash",
            formattedQuote: "$40.30",
            formattedPriceChange: "0.00004829 BCH"
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
                    rows: accountPickerRowList,
                    header: simpleHeader
                ),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment()
            )
        )
    }
}
