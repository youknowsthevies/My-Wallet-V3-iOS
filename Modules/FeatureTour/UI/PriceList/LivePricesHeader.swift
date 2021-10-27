// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import SwiftUI

struct LivePricesHeader: View {

    @State private var circleIsVisible = true

    @Binding var offset: CGFloat

    private let titleHeight: CGFloat = 64
    private var clippedTitleHeight: CGFloat {
        let calculatedHeight = titleHeight + offset
        switch calculatedHeight {
        case _ where calculatedHeight <= 0:
            return 0
        case _ where calculatedHeight >= titleHeight:
            return titleHeight
        default:
            return calculatedHeight
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text(LocalizationConstants.Tour.carouselPricesScreenTitle)
                    .multilineTextAlignment(.center)
                    .frame(width: 180.0, height: titleHeight)
                    .textStyle(.title)
            }
            .frame(width: 180.0, height: clippedTitleHeight)
            .clipped()
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color.green)
                    .animation(nil)
                    .frame(width: 8, height: 8)
                    .opacity(circleIsVisible ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    .onAppear {
                        circleIsVisible.toggle()
                    }
                Text(LocalizationConstants.Tour.carouselPricesScreenLivePrices)
                    .textStyle(.heading)
            }
        }
    }
}
