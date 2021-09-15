// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import SwiftUI

struct PriceListHeader: View {

    @State private var circleIsVisible = true
    @Binding var titleIsVisible: Bool

    var body: some View {
        VStack(spacing: 16) {
            if titleIsVisible {
                Text(LocalizationConstants.Tour.carouselPricesScreenTitle)
                    .multilineTextAlignment(.center)
                    .frame(width: 180.0)
                    .textStyle(.title)
                    .transition(AnyTransition.move(edge: .top))
            }
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .opacity(circleIsVisible ? 1 : 0)
                    .animation(.easeIn, value: titleIsVisible)
                    .animation(Animation.linear(duration: 1).repeatForever())
                    .onAppear {
                        self.circleIsVisible = false
                    }
                Text(LocalizationConstants.Tour.carouselPricesScreenLivePrices)
                    .textStyle(.heading)
            }
        }
    }
}
