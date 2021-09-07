// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

public struct TourView: View {

    let store: Store<TourState, TourAction>

    init(store: Store<TourState, TourAction>) {
        self.store = store
    }

    public init() {
        self.init(
            store: Store(
                initialState: TourState(),
                reducer: tourReducer,
                environment: TourEnvironment()
            )
        )
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                makeTabView()
                makeFixedView(viewStore)
            }
            .background(AnimatedGradient().ignoresSafeArea(.all))
        }
    }
}

extension TourView {

    public enum Carousel {
        case brokerage
        case earn
        case keys

        @ViewBuilder public func makeView() -> some View {
            switch self {
            case .brokerage:
                makeCarouselView(
                    image: Image("bitcoin_perspective", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselBrokerageScreenMessage
                )
            case .earn:
                makeCarouselView(
                    image: Image("rocket", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselEarnScreenMessage
                )
            case .keys:
                makeCarouselView(
                    image: Image("lock", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselKeysScreenMessage
                )
            }
        }

        @ViewBuilder private func makeCarouselView(image: Image?, text: String) -> some View {
            VStack(spacing: 25) {
                if let image = image {
                    image
                }
                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(width: 200.0)
                    .textStyle(.title)
            }
            .padding(.bottom, 112)
        }
    }

    @ViewBuilder private func makeTabView() -> some View {
        TabView {
            Carousel.brokerage.makeView()
            Carousel.earn.makeView()
            Carousel.keys.makeView()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    @ViewBuilder private func makeFixedView(_ viewStore: ViewStore<TourState, TourAction>) -> some View {
        VStack(spacing: 16) {
            Image("logo-blockchain-black", bundle: Bundle.featureTour)
            Spacer()
            PrimaryButton(title: LocalizationConstants.Tour.createAccountButtonTitle) {
                viewStore.send(.createAccount)
            }
        }
        .padding(.top)
        .padding(.bottom, 60)
        .padding(.horizontal, 24)
    }
}

struct TourView_Previews: PreviewProvider {
    static var previews: some View {
        TourView()
    }
}
