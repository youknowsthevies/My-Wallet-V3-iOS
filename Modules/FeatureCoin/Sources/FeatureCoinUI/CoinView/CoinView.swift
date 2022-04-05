// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public struct CoinView: View {

    let store: Store<CoinViewState, CoinViewAction>
    @BlockchainApp var app

    @Environment(\.context) var context

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
    }

    typealias Localization = LocalizationConstants.Coin

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    header(viewStore)
                    accounts(viewStore)
                    about(viewStore)
                    Color.clear
                        .frame(height: Spacing.padding2)
                }
                if viewStore.accounts.isNotEmpty {
                    actions(viewStore)
                }
            }
            .primaryNavigation(
                leading: {
                    navigationLeadingView(
                        url: viewStore.asset.logoUrl,
                        image: viewStore.asset.logoImage
                    )
                },
                title: viewStore.asset.name,
                trailing: {
                    dismiss(viewStore)
                }
            )
            .padding(.bottom, 20.pt)
            .ignoresSafeArea(.container, edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .bottomSheet(
                item: viewStore.binding(\.$account).animation(.spring()),
                content: { account in
                    AccountSheet(
                        account: account,
                        isVerified: viewStore.kycStatus != .unverified,
                        onClose: {
                            withAnimation(.spring()) {
                                viewStore.send(.set(\.$account, nil))
                            }
                        }
                    )
                    .context([blockchain.ux.asset.account.id: account.id])
                }
            )
            .bottomSheet(
                item: viewStore.binding(\.$explainer).animation(.spring()),
                content: { account in
                    AccountExplainer(
                        account: account,
                        onClose: {
                            withAnimation(.spring()) {
                                viewStore.send(.set(\.$explainer, nil))
                            }
                        }
                    )
                    .context([blockchain.ux.asset.account.id: account.id])
                }
            )
        }
    }

    @ViewBuilder func header(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        GraphView(
            store: store.scope(state: \.graph, action: CoinViewAction.graph)
        )
    }

    @ViewBuilder func totalBalance(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        switch viewStore.isFavorite {
        case true:
            TotalBalanceView(
                asset: viewStore.asset,
                accounts: viewStore.accounts,
                trailing: {
                    IconButton(icon: .favorite) {
                        viewStore.send(.addToWatchlist)
                    }
                }
            )
        case false:
            TotalBalanceView(
                asset: viewStore.asset,
                accounts: viewStore.accounts,
                trailing: {
                    IconButton(icon: .favoriteEmpty) {
                        viewStore.send(.removeFromWatchlist)
                    }
                }
            )
        default:
            TotalBalanceView(
                asset: viewStore.asset,
                accounts: viewStore.accounts,
                trailing: {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            )
        }
    }

    @ViewBuilder func accounts(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        VStack {
            if viewStore.error == .failedToLoad {
                AlertCard(
                    title: Localization.Accounts.Error.title,
                    message: Localization.Accounts.Error.message,
                    variant: .error,
                    isBordered: true
                )
                .padding([.leading, .trailing, .top], Spacing.padding2)
            } else if viewStore.asset.isTradable {
                totalBalance(viewStore)
                if let status = viewStore.kycStatus {
                    AccountListView(
                        accounts: viewStore.accounts,
                        assetColor: viewStore.asset.brandColor,
                        interestRate: viewStore.interestRate,
                        kycStatus: status
                    )
                }
            } else {
                totalBalance(viewStore)
                AlertCard(
                    title: Localization.Label.Title.notTradable.interpolating(
                        viewStore.asset.name,
                        viewStore.asset.code
                    ),
                    message: Localization.Label.Title.notTradableMessage.interpolating(
                        viewStore.asset.name,
                        viewStore.asset.code
                    )
                )
                .padding([.leading, .trailing, .top], Spacing.padding2)
            }
        }
    }

    @ViewBuilder func about(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        HStack {
            VStack(alignment: .leading) {
                if let about = viewStore.asset.about {
                    Text(
                        Localization.Label.Title.aboutCrypto
                            .interpolating(viewStore.asset.name)
                    )
                    .typography(.body2)
                    .padding(Spacing.padding3)

                    Text(about)
                        .typography(.paragraph1)
                        .padding([.leading, .trailing], 24.pt)
                }
                if let url = viewStore.asset.website {
                    SmallMinimalButton(title: Localization.Link.Title.visitWebsite) {
                        app.post(
                            event: blockchain.ux.asset.bio.visit.website[].ref(to: context),
                            context: [blockchain.ux.asset.bio.visit.website.url[]: url]
                        )
                    }
                    .padding(Spacing.padding3)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder func navigationLeadingView(url: URL?, image: Image?) -> some View {
        if let logoImage = image {
            logoImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .frame(width: 24.pt, height: 24.pt)
        } else {
            Backport.AsyncImage(
                url: url,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                }, placeholder: {
                    Color.semantic.muted
                        .overlay(
                            ProgressView()
                                .progressViewStyle(.circular)
                        )
                        .clipShape(Circle())
                }
            )
            .frame(width: 24.pt, height: 24.pt)
        }
    }

    @ViewBuilder func dismiss(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        IconButton(icon: .closev2.circle()) {
            viewStore.send(.dismiss)
        }
        .frame(width: 24.pt, height: 24.pt)
    }

    @ViewBuilder func actions(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        VStack {
            let actions = viewStore.actions
            if actions.isNotEmpty {
                PrimaryDivider()
            }
            HStack {
                ForEach(actions.indexed(), id: \.element.event) { index, action in
                    if index == actions.index(before: actions.endIndex) {
                        PrimaryButton(
                            title: action.title,
                            leadingView: { action.icon },
                            action: {
                                app.post(event: action.event[].ref(to: context))
                            }
                        )
                    } else {
                        SecondaryButton(
                            title: action.title,
                            leadingView: { action.icon },
                            action: {
                                app.post(event: action.event[].ref(to: context))
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// swiftlint:disable type_name
struct CoinView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(),
                    kycStatus: .gold,
                    accounts: [
                        .preview.privateKey,
                        .preview.trading,
                        .preview.rewards
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDevice("iPhone SE (2nd generation)")
        .previewDisplayName("Gold iPhone SE (2nd generation)")

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(),
                    kycStatus: .gold,
                    accounts: [
                        .preview.privateKey,
                        .preview.trading,
                        .preview.rewards
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDisplayName("Gold")

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(
                        isTradable: true
                    ),
                    kycStatus: .silver,
                    accounts: [
                        .preview.privateKey,
                        .preview.trading,
                        .preview.rewards
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDisplayName("Silver")

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(
                        isTradable: false
                    ),
                    kycStatus: .unverified,
                    accounts: [
                        .new(
                            cryptoCurrency: .bitcoin,
                            fiatCurrency: .USD,
                            crypto: .zero(currency: .bitcoin),
                            fiat: .zero(currency: .USD)
                        )
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDisplayName("Not Tradable")

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(),
                    kycStatus: .unverified,
                    accounts: [
                        .preview.privateKey,
                        .preview.trading
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDisplayName("Unverified")

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(),
                    kycStatus: .unverified,
                    accounts: [],
                    error: .failedToLoad
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)
        .previewDisplayName("Error")
    }
}
