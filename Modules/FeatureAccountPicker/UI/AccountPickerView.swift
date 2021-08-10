import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI

public struct AccountPickerView: View {

    let store: Store<AccountPickerState, AccountPickerAction>

    public var body: some View {
        WithViewStore(self.store) { _ in
            NavigationView {
                GeometryReader { geometry in
                    List {
                        Text("Which wallet do you want to Swap from?")
                            .frame(height: geometry.size.height * 0.1)
                        ForEachStore(
                            self.store.scope(
                                state: \.rows,
                                action: AccountPickerAction.accountPickerRow(id:action:)
                            ),
                            content: AccountPickerRowView.init(store:)
                        )
                    }.listStyle(GroupedListStyle())
                }.navigationTitle("Swap")
            }
        }
    }
}

struct AccountPickerView_Previews: PreviewProvider {

    static let accountPickerRowMocks: IdentifiedArrayOf<AccountPickerRow> = [
        AccountPickerRow(name: "BTC Wallet", kind: "Bitcoin", price: "$2,302.39", value: "0.21204887 BTC"),
        AccountPickerRow(name: "BTC Trading Wallet", kind: "Bitcoin", price: "$10,093.13", value: "1.38294910 BTC"),
        AccountPickerRow(name: "ETH Wallet", kind: "Ethereum", price: "$807.21", value: "0.17039384 ETH"),
        AccountPickerRow(name: "BCH Wallet", kind: "Bitcoin Cash", price: "$807.21", value: "0.00388845 BCH"),
        AccountPickerRow(name: "BCH Trading Wallet", kind: "Bitcoin Cash", price: "$40.30", value: "0.00004829 BCH"),

        AccountPickerRow(name: "BTC Wallet", kind: "Bitcoin", price: "$2,302.39", value: "0.21204887 BTC"),
        AccountPickerRow(name: "BTC Trading Wallet", kind: "Bitcoin", price: "$10,093.13", value: "1.38294910 BTC"),
        AccountPickerRow(name: "ETH Wallet", kind: "Ethereum", price: "$807.21", value: "0.17039384 ETH"),
        AccountPickerRow(name: "BCH Wallet", kind: "Bitcoin Cash", price: "$807.21", value: "0.00388845 BCH"),
        AccountPickerRow(name: "BCH Trading Wallet", kind: "Bitcoin Cash", price: "$40.30", value: "0.00004829 BCH"),

        AccountPickerRow(name: "BTC Wallet", kind: "Bitcoin", price: "$2,302.39", value: "0.21204887 BTC"),
        AccountPickerRow(name: "BTC Trading Wallet", kind: "Bitcoin", price: "$10,093.13", value: "1.38294910 BTC"),
        AccountPickerRow(name: "ETH Wallet", kind: "Ethereum", price: "$807.21", value: "0.17039384 ETH"),
        AccountPickerRow(name: "BCH Wallet", kind: "Bitcoin Cash", price: "$807.21", value: "0.00388845 BCH"),
        AccountPickerRow(name: "BCH Trading Wallet", kind: "Bitcoin Cash", price: "$40.30", value: "0.00004829 BCH")
    ]

    static var previews: some View {
        AccountPickerView(
            store: Store(
                initialState: AccountPickerState(rows: accountPickerRowMocks),
                reducer: accountPickerReducer,
                environment: AccountPickerEnvironment()
            )
        )
    }
}
