// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI

struct PriceListView: View {

    let store: Store<PriceListState, PriceListAction>

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
            }.padding(.top)
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
    static var previews: some View {
        PriceListFactory.makePriceList()
    }
}
