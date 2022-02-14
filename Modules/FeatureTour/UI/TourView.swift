// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import Localization
import SwiftUI

public struct TourView: View {

    let store: Store<TourState, TourAction>

    private let list: LivePricesList

    @State var manualLoginEnabled: Bool

    init(store: Store<TourState, TourAction>, manualLoginEnabled: Bool) {
        self.store = store
        self.manualLoginEnabled = manualLoginEnabled
        list = LivePricesList(store: store)
    }

    public init(environment: TourEnvironment, manualLoginEnabled: Bool) {
        self.init(
            store: Store(
                initialState: TourState(),
                reducer: tourReducer,
                environment: environment
            ),
            manualLoginEnabled: manualLoginEnabled
        )
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Image("logo-blockchain-black", bundle: Bundle.featureTour)
                    .padding(.top)
                    .padding(.horizontal, 24)
                ZStack {
                    makeTabView()
                    makeButtonsView(viewStore)
                }
                .background(
                    ZStack {
                        list
                        Color.white.ignoresSafeArea()
                        Image("gradient", bundle: Bundle.featureTour)
                            .resizable()
                            .opacity(viewStore.gradientBackgroundOpacity)
                            .ignoresSafeArea(.all)
                    }
                )
            }
            .onAppear {
                viewStore.send(.loadPrices)
            }
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
                    image: Image("carousel-brokerage", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselBrokerageScreenMessage
                )
            case .earn:
                makeCarouselView(
                    image: Image("carousel-rewards", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselEarnScreenMessage
                )
            case .keys:
                makeCarouselView(
                    image: Image("carousel-security", bundle: Bundle.featureTour),
                    text: LocalizationConstants.Tour.carouselKeysScreenMessage
                )
            }
        }

        @ViewBuilder private func makeCarouselView(image: Image?, text: String) -> some View {
            VStack {
                if let image = image {
                    image
                        .frame(height: 280.0)
                }
                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(width: 200.0)
                    .textStyle(.title)
            }
            .padding(.bottom, 180)
        }
    }

    @ViewBuilder private func makeTabView() -> some View {
        TabView {
            Carousel.brokerage.makeView()
            Carousel.earn.makeView()
            Carousel.keys.makeView()
            LivePricesView(store: store, list: list)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }

    @ViewBuilder private func makeButtonsView(_ viewStore: ViewStore<TourState, TourAction>) -> some View {
        VStack(spacing: 16) {
            Spacer()
            PrimaryButton(title: LocalizationConstants.Tour.createAccountButtonTitle) {
                viewStore.send(.createAccount)
            }
            if manualLoginEnabled {
                SecondaryButton(title: LocalizationConstants.Tour.manualLoginButtonTitle) {
                    viewStore.send(.manualLogin)
                }
            }
            MinimalDoubleButton(
                leadingTitle: LocalizationConstants.Tour.restoreButtonTitle,
                leadingAction: { viewStore.send(.restore) },
                trailingTitle: LocalizationConstants.Tour.loginButtonTitle,
                trailingAction: { viewStore.send(.logIn) }
            )
        }
        .padding(.top)
        .padding(.bottom, 60)
        .padding(.horizontal, 24)
    }
}

struct TourView_Previews: PreviewProvider {
    static var previews: some View {
        TourView(
            environment: TourEnvironment(
                createAccountAction: {},
                restoreAction: {},
                logInAction: {},
                manualLoginAction: {}
            ),
            manualLoginEnabled: false
        )
    }
}
