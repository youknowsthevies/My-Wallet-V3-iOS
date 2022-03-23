//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import ComposableNavigation
import DIKit
import Localization
import MoneyKit
import SwiftUI

struct Tab: Hashable, Identifiable {
    var id: String { tag.id }
    var tag: Tag
    var name: String
    var icon: Icon
}

extension Tab: CustomStringConvertible {

    var description: String { id }
}

extension Tab {

    typealias Localization = LocalizationConstants.TabItems

    static let allTabs: [L: Tab] = [
        blockchain.ux.user.portfolio: Tab(
            tag: blockchain.ux.user.portfolio[],
            name: Localization.home,
            icon: .home
        ),
        blockchain.ux.prices: Tab(
            tag: blockchain.ux.prices[],
            name: Localization.prices,
            icon: .lineChartUp
        ),
        blockchain.ux.buy_and_sell: Tab(
            tag: blockchain.ux.buy_and_sell[],
            name: Localization.buyAndSell,
            icon: .cart
        ),
        blockchain.ux.user.activity: Tab(
            tag: blockchain.ux.user.activity[],
            name: Localization.activity,
            icon: .pending
        )
    ]

    func entry() -> Tag {
        tag["entry"]!
    }
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
            Group {
                TabView(selection: viewStore.binding(\.$tab)) {
                    tab(blockchain.ux.user.portfolio) {
                        PortfolioView(store: store.stateless)
                    }
                    tab(blockchain.ux.prices) {
                        PricesView(store: store.stateless)
                    }
                    fab()
                    tab(blockchain.ux.buy_and_sell) {
                        BuySellView(selectedSegment: viewStore.binding(\.$buyAndSell.segment))
                    }
                    tab(blockchain.ux.user.activity) {
                        ActivityView()
                    }
                }
                .overlay(
                    FloatingActionButton(isOn: viewStore.binding(\.$fab.isOn).animation(.spring()))
                        .identity(blockchain.ux.frequent.action)
                        .background(
                            Circle()
                                .fill(Color.semantic.background)
                                .padding(8)
                        )
                        .pulse(enabled: viewStore.fab.animate, inset: 8)
                        .padding([.leading, .trailing], 24.pt)
                        .offset(y: 6.pt)
                        .contentShape(Rectangle())
                        .background(Color.white.invisible()),
                    alignment: .bottom
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .bottomSheet(isPresented: viewStore.binding(\.$fab.isOn).animation(.spring())) {
                FrequentActionView(
                    list: viewStore.fab.data.list,
                    buttons: viewStore.fab.data.buttons
                ) { action in
                    withAnimation {
                        viewStore.send(.frequentAction(action))
                    }
                }
            }
            .on(blockchain.ux.home.tab.select) { event in
                try viewStore.send(.tab(event.reference.context.decode(blockchain.ux.home.tab.id, as: Tag.self)))
                viewStore.send(.dismiss())
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onDisappear {
                viewStore.send(.onDisappear)
            }
        }
        .observer(CoinViewObserver())
        .navigationRoute(in: store)
        .app(Blockchain.app)
    }

    func fab() -> some View {
        Icon.blockchain
            .frame(width: 32.pt, height: 32.pt)
            .tabItem { Color.clear }
    }

    @ViewBuilder func tab<Content>(
        _ id: L,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content: View {
        let tab = Tab.allTabs[id]!
        PrimaryNavigationView {
            content()
                .primaryNavigation(
                    leading: {
                        account()
                    },
                    title: tab.name,
                    trailing: {
                        QR()
                    }
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
            .identity(tab.entry())
        }
        .tag(tab.tag)
        .identity(tab.tag)
    }

    func tab<Content, Scope>(
        _ id: L,
        state: @escaping (RootViewState) -> Scope,
        @ViewBuilder content: @escaping (Scope) -> Content
    ) -> some View where Content: View, Scope: Equatable {
        WithViewStore(store.scope(state: state)) { viewStore in
            self.tab(id) { content(viewStore.state) }
        }
    }

    @ViewBuilder func QR() -> some View {
        WithViewStore(store.stateless) { viewStore in
            IconButton(icon: .qrCode) {
                viewStore.send(.enter(into: .QR, context: .none))
            }
            .identity(blockchain.ux.scan.QR.entry)
        }
    }

    @ViewBuilder func account() -> some View {
        WithViewStore(store.stateless) { viewStore in
            IconButton(icon: .user) {
                viewStore.send(.enter(into: .account, context: .none))
            }
            .identity(blockchain.ux.user.account.entry)
        }
    }
}

extension Color {

    /// A workaround to ensure taps are not passed through to the view behind
    func invisible() -> Color {
        opacity(0.001)
    }
}

extension View {

    @ViewBuilder
    func identity(_ tag: L) -> some View {
        identity(tag[])
    }

    @ViewBuilder
    func identity(_ tag: Tag) -> some View {
        identity(tag.reference)
    }

    @ViewBuilder
    func identity(_ tag: Tag.Reference) -> some View {
        id(tag.string)
            .accessibility(identifier: tag.string)
    }
}
