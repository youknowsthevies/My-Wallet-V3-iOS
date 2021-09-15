// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct PriceView: View {

    let store: Store<Price, PriceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 16) {
                if let image = viewStore.icon {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32.0, height: 32.0)
                }
                VStack(spacing: 2) {
                    HStack {
                        Text(viewStore.title)
                            .textStyle(.heading)
                        Spacer()
                        Text(viewStore.price)
                            .textStyle(.heading)
                    }
                    HStack {
                        Text(viewStore.abbreviation)
                            .textStyle(.subheading)
                        Spacer()
                        Text(viewStore.percentage)
                            .foregroundColor(viewStore.hasIncreased ? .positiveTrend : .negativeTrend)
                            .textStyle(.subheading)
                    }
                }
            }
            .padding([.top, .bottom], 10)
            .padding(.horizontal)
        }
    }
}
