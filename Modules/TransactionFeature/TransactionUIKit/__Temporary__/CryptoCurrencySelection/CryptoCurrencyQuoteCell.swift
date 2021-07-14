// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import PlatformUIKit // replace me with MoneyUIKit when available
import SwiftUI
import TransactionKit
import UIComponentsKit

enum CryptoCurrencyQuoteAction: Equatable {
    case select(CryptoCurrencyQuote)
}

struct CryptoCurrencyQuoteCell: View {

    let store: Store<CryptoCurrencyQuote, CryptoCurrencyQuoteAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.viewPrimaryBackground)
                    .contentShape(Rectangle())
                VStack {
                    HStack(spacing: 16) {
                        if case let .image(image) = viewStore.cryptoCurrency.logoResource.resource {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32.0, height: 32.0)
                        }
                        VStack(alignment: .leading, spacing: .zero) {
                            Text(viewStore.cryptoCurrency.name)
                                .textStyle(.heading)
                            HStack {
                                Text(viewStore.formattedQuote)
                                    .textStyle(.body)
                                Text(viewStore.formattedPriceChange)
                                    .foregroundColorBasedOnPercentageChange(viewStore.priceChange)
                                    .textStyle(.body)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8.0, height: 12.0)
                            .foregroundColor(.disclosureIndicator)
                    }
                    .padding([.top, .bottom], 10)
                }
            }
            .onTapGesture {
                viewStore.send(.select(viewStore.state))
            }
        }
    }
}
