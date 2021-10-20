// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

struct PriceListView: View {

    let store: Store<PriceListState, PriceListAction>

    init(
        store: Store<PriceListState, PriceListAction> = Store(
            initialState: PriceListState(),
            reducer: priceListReducer,
            environment: PriceListEnvironment()
        )
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                PriceListHeader(
                    titleIsVisible: viewStore.binding(
                        get: \.onTop,
                        send: PriceListAction.none
                    )
                )
                .animation(.easeIn)
                ZStack {
                    VStack {}
                    makeList().mask(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [
                                    Color.black,
                                    Color.black,
                                    Color.black.opacity(0.2),
                                    Color.black.opacity(0.03)
                                ]
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onPreferenceChange(OffsetKey.self) {
                        viewStore.send(.listDidScroll(offset: $0))
                    }
                }
            }
            .padding(.top)
            .onAppear {
                viewStore.send(.loadPrices)
            }
        }
    }

    @ViewBuilder private func makeList() -> some View {
        GeometryReader { reader in
            ScrollView {
                LazyVStack {
                    ForEachStore(
                        self.store.scope(
                            state: \.items,
                            action: PriceListAction.price(id:action:)
                        ),
                        content: PriceView.init(store:)
                    )
                    Color.clear.padding(.bottom, 180) // contentInset
                }
                .anchorPreference(key: OffsetKey.self, value: .top) {
                    reader[$0].y
                }
                .background(Color.clear)
                .padding(.horizontal)
            }
        }
    }
}

private struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct PriceListView_Previews: PreviewProvider {

    static let items = [
        Price(currency: .coin(.bitcoin), value: .loaded(next: "$55,343.76"), deltaPercentage: .loaded(next: 7.88)),
        Price(currency: .coin(.ethereum), value: .loaded(next: "$3,585.69"), deltaPercentage: .loaded(next: 1.82)),
        Price(currency: .coin(.bitcoinCash), value: .loaded(next: "$618.05"), deltaPercentage: .loaded(next: -3.46)),
        Price(currency: .coin(.stellar), value: .loaded(next: "$0.36"), deltaPercentage: .loaded(next: 12.50))
    ]

    static var priceListState: PriceListState {
        var priceListState = PriceListState()
        priceListState.items = IdentifiedArray(uniqueElements: items)
        return priceListState
    }

    static var reducer: Reducer<PriceListState, PriceListAction, PriceListEnvironment> = Reducer { _, _, _ in
        .none
    }

    static var previews: some View {
        PriceListView(
            store: Store(
                initialState: priceListState,
                reducer: reducer,
                environment: PriceListEnvironment()
            )
        )
    }
}
