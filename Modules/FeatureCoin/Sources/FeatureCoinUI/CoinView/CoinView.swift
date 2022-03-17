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
    @Environment(\.presentationMode) private var presentationMode

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
                }
                if viewStore.accounts.isNotEmpty {
                    actions(viewStore)
                }
            }
            .padding(.bottom, 20.pt)
            .ignoresSafeArea(.container, edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { app.post(event: blockchain.ux.asset[].ref(to: context)) }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
            .bottomSheet(
                item: viewStore.binding(\.$account).animation(.spring()),
                content: { account in
                    AccountSheet(
                        account: account,
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
        Group {
            GraphView(
                store: store.scope(state: \.graph, action: CoinViewAction.graph)
            )
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
                dismiss()
            }
        )
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
                TotalBalanceView(
                    asset: viewStore.asset,
                    accounts: viewStore.accounts
                )
                AccountListView(
                    accounts: viewStore.accounts,
                    assetColor: viewStore.asset.brandColor,
                    interestRate: viewStore.interestRate
                )
            } else {
                TotalBalanceView(
                    asset: viewStore.asset,
                    accounts: viewStore.accounts
                )
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

    @ViewBuilder func dismiss() -> some View {
        IconButton(icon: .closev2.circle()) {
            presentationMode.wrappedValue.dismiss()
        }
        .frame(width: 24.pt, height: 24.pt)
    }

    @ViewBuilder func actions(_ viewStore: ViewStore<CoinViewState, CoinViewAction>) -> some View {
        VStack {
            if viewStore.primaryAction != nil || viewStore.secondaryAction != nil {
                PrimaryDivider()
            }
            HStack {
                if let action = viewStore.secondaryAction {
                    SecondaryButton(
                        title: action.title,
                        leadingView: { action.icon },
                        action: {
                            app.post(event: action.event[].ref(to: context))
                        }
                    )
                }
                if let action = viewStore.primaryAction {
                    PrimaryButton(
                        title: action.title,
                        leadingView: { action.icon },
                        action: {
                            app.post(event: action.event[].ref(to: context))
                        }
                    )
                }
            }
            .padding()
        }
        .padding([.leading, .trailing], 8.pt)
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
                        .preview(),
                        .preview(
                            name: "Trading Account",
                            accountType: .trading
                        ),
                        .preview(
                            name: "Rewards Account",
                            accountType: .interest
                        )
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(
                        isTradable: true
                    ),
                    kycStatus: .silver,
                    accounts: [
                        .preview()
                    ]
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(
                        isTradable: false
                    ),
                    kycStatus: .unverified,
                    accounts: []
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)

        CoinView(
            store: .init(
                initialState: .init(
                    asset: .preview(),
                    kycStatus: .unverified,
                    accounts: []
                ),
                reducer: coinViewReducer,
                environment: .preview
            )
        )
        .app(App.preview)

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
    }
}
