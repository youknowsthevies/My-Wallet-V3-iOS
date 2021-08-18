// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI
import UIComponentsKit

struct AccountPickerRowView: View {

    let store: Store<AccountPickerRow, AccountPickerRowAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.viewPrimaryBackground)
                    .contentShape(Rectangle())
                switch viewStore.kind {
                case .accountGroup(let model):
                    AccountGroupRow(model: model)
                default:
                    Text("default")
                }
            }.onTapGesture {
                viewStore.send(.accountPickerRowDidTap(title: viewStore.id.uuidString))
            }
        }
    }
}

private struct AccountGroupRow: View {

    let model: AccountPickerRow.AccountGroupModel

    var body: some View {
        HStack(spacing: 16) {
            if let image = model.logo {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0, height: 32.0)
            }
            VStack {
                HStack {
                    Text(model.title)
                        .textStyle(.heading)
                    Spacer()
                    Text(model.fiatBalance)
                        .textStyle(.heading)
                }
                HStack {
                    Text(model.description)
                        .textStyle(.body)
                    Spacer()
                    Text(model.cryptoBalance)
                        .textStyle(.body)
                }
            }
        }
        .padding([.top, .bottom], 10)
    }
}

struct AccountPickerRowView_Previews: PreviewProvider {

    static let accountPickerRow = AccountPickerRow.AccountGroupRowMockFactory.makeRow(
        name: "BTC Trading Wallet",
        description: "Bitcoin",
        formattedQuote: "$2,302.39",
        formattedPriceChange: "0.21204887 BTC"
    )

    static var previews: some View {
        AccountPickerRowView(
            store: Store(
                initialState: accountPickerRow,
                reducer: accountPickerRowReducer,
                environment: AccountPickerRowEnvironment()
            )
        )
    }
}
