//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import ComponentLibrary
import ComposableArchitecture
import ComposableNavigation
import Localization
import SwiftUI

struct Tab: Hashable, Identifiable {
    var id: Tab { self }
    var name: String
    var icon: Icon
}

extension Tab {

    typealias Localization = LocalizationConstants.TabItems

    static let home = Tab(
        name: Localization.home,
        icon: .home
    )
    static let prices = Tab(
        name: Localization.prices,
        icon: .lineChartUp
    )
    static let buyAndSell = Tab(
        name: Localization.buyAndSell,
        icon: .cart
    )
    static let activity = Tab(
        name: Localization.activity,
        icon: .pending
    )
}

struct RootView: View {

    let store: Store<RootViewState, RootViewAction>

    init(store: Store<RootViewState, RootViewAction>) {
        self.store = store
        setupApperance()
    }

    func setupApperance() {
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().tintColor = .brandPrimary
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$tab)) {
                tab(.home) {
                    PortfolioView()
                }
                tab(.prices) {
                    PricesView()
                }
                fab()
                tab(.buyAndSell, state: \.buyAndSell) { context in
                    BuySellView(selectedSegment: context.segment)
                }
                tab(.activity) {
                    ActivityView()
                }
            }
            .overlay(
                FloatingActionButton(isOn: viewStore.binding(\.$fab))
                    .padding([.leading, .bottom, .trailing], 16.pt)
                    .contentShape(Rectangle())
                    .offset(y: 24.pt),
                alignment: .bottom
            )
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .bottomSheet(isPresented: viewStore.binding(\.$fab)) {
                FrequentActionView { action in
                    viewStore.send(.frequentAction(action))
                }
            }
        }
        .navigationRoute(in: store)
    }

    func fab() -> some View {
        Spacer()
            .tabItem { Spacer() }
    }

    func tab<Content>(
        _ tab: Tab,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        PrimaryNavigationView {
            content()
                .primaryNavigation(
                    title: tab.name,
                    trailing: navigationButtons
                )
        }
        .tabItem {
            Label(
                title: {
                    Text(tab.name)
                        .typography(.micro)
                },
                icon: { tab.icon.image }
            )
        }
        .id(tab)
        .tag(tab)
    }

    func tab<Content, Scope>(
        _ tab: Tab,
        state: @escaping (RootViewState) -> Scope,
        @ViewBuilder content: @escaping (Scope) -> Content
    ) -> some View where Content: View, Scope: Equatable {
        WithViewStore(store.scope(state: state)) { viewStore in
            self.tab(tab) { content(viewStore.state) }
        }
    }

    @ViewBuilder func navigationButtons() -> some View {
        HStack(spacing: Spacing.padding3) {
            QR()
            account()
        }
    }

    @ViewBuilder func QR() -> some View {
        WithViewStore(store.stateless) { viewStore in
            IconButton(icon: .qrCode) {
                viewStore.send(.enter(into: .QR, context: .none))
            }
        }
    }

    @ViewBuilder func account() -> some View {
        WithViewStore(store.stateless) { viewStore in
            IconButton(icon: .user) {
                viewStore.send(.enter(into: .account, context: .none))
            }
        }
    }
}
