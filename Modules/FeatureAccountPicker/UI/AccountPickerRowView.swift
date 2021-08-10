// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI

struct AccountPickerRowView: View {
    let store: Store<AccountPickerRow, AccountPickerRowAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 10) {
                HStack {
                    Text(viewStore.name)
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Text(viewStore.name)
                        .font(.footnote)
                        .frame(alignment: .trailing)
                }
                HStack {
                    Text(viewStore.name)
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Text(viewStore.name)
                        .font(.footnote)
                        .foregroundColor(Color.gray)
                        .frame(alignment: .trailing)
                }
            }
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                viewStore.send(.accountPickerRowDidTap(name: viewStore.name))
            }
        }
    }
}

struct AccountPickerRowView_Previews: PreviewProvider {
    static var previews: some View {
        AccountPickerRowView(
            store: Store(
                initialState: AccountPickerRow(
                    name: "BTC Wallet",
                    kind: "Bitcoin",
                    price: "$2,302.39",
                    value: "0.21204887 BTC"
                ),
                reducer: accountPickerRowReducer,
                environment: AccountPickerRowEnvironment()
            )
        )
    }
}
