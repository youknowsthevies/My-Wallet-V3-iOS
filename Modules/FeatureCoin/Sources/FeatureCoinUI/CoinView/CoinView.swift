// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public struct CoinView: View {

    let store: Store<CoinViewState, CoinViewAction>

    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) private var presentationMode

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
    }

    typealias Localization = LocalizationConstants.Coin

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                ScrollView {
                    GraphView(
                        store: store.scope(state: \.graph, action: CoinViewAction.graph)
                    )

                    if !viewStore.accounts.isEmpty {
                        TotalBalanceView(
                            assetDetails: viewStore.assetDetails,
                            accounts: viewStore.accounts
                        ) {
                            IconButton(icon: .favorite) {}
                        }
                    }

                    if viewStore.assetDetails.tradeable, !viewStore.accounts.isEmpty {
                        AccountsView(
                            assetColor: viewStore.assetDetails.brandColor,
                            accounts: viewStore.accounts
                        )
                    } else {
                        AlertCard(
                            title: Localization.Label.Title.notTradable.interpolating(
                                viewStore.assetDetails.name,
                                viewStore.assetDetails.code
                            ),
                            message: Localization.Label.Title.addToWatchListInfo.interpolating(
                                viewStore.assetDetails.name
                            )
                        )
                        .padding([.leading, .trailing, .top], Spacing.padding2)
                    }

                    HStack {
                        Text(
                            Localization.Label.Title.aboutCrypto
                                .interpolating(viewStore.assetDetails.name)
                        )
                        .typography(.body2)
                        .padding(Spacing.padding3)

                        Spacer()
                    }

                    Text(viewStore.assetDetails.about)
                        .typography(.paragraph1)
                        .padding([.leading, .trailing], 24.pt)

                    HStack {
                        SmallMinimalButton(title: Localization.Link.Title.visitWebsite) {
                            openURL(viewStore.assetDetails.assetInfoUrl)
                        }
                        .padding(Spacing.padding3)

                        Spacer()
                    }
                }
                if viewStore.primaryAction != nil || viewStore.secondaryAction != nil {
                    PrimaryDivider()

                    DoubleButton(
                        primaryAction: viewStore.primaryAction,
                        secondaryAction: viewStore.secondaryAction,
                        action: { _ in }
                    )
                    .padding([.leading, .trailing], Spacing.padding1)
                }
            }
            .onAppear {
                viewStore.send(.loadKycStatus)
                viewStore.send(.loadAccounts)
            }
            .primaryNavigation(
                leading: {
                    leading(
                        logoUrl: viewStore.assetDetails.logoUrl,
                        logoImage: viewStore.assetDetails.logoImage
                    )
                },
                title: viewStore.assetDetails.name,
                trailing: {
                    dismiss()
                }
            )
        }
    }

    @ViewBuilder func leading(logoUrl: URL?, logoImage: Image?) -> some View {
        if let logoImage = logoImage {
            logoImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(12)
                .frame(width: 24.pt, height: 24.pt)
        } else {
            Backport.AsyncImage(
                url: logoUrl,
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
}

// swiftlint:disable type_name
struct CoinView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            CoinView(
                store: .init(
                    initialState: .init(
                        assetDetails: PreviewHelper.assetDetails(),
                        kycStatus: .gold,
                        accounts: [
                            PreviewHelper.account(),
                            PreviewHelper.account(
                                name: "Trading Account",
                                accountType: .trading
                            ),
                            PreviewHelper.account(
                                name: "Rewards Account",
                                accountType: .interest
                            )
                        ]
                    ),
                    reducer: coinViewReducer,
                    environment: .init(
                        kycStatusProvider: { .empty() },
                        accountsProvider: { .empty() },
                        historicalPriceService: PreviewHelper.HistoricalPriceService()
                    )
                )
            )
        }

        CoinView(
            store: .init(
                initialState: .init(
                    assetDetails: PreviewHelper.assetDetails(
                        tradeable: true
                    ),
                    kycStatus: .silver,
                    accounts: [
                        PreviewHelper.account()
                    ]
                ),
                reducer: coinViewReducer,
                environment: .init(
                    kycStatusProvider: { .empty() },
                    accountsProvider: { .empty() },
                    historicalPriceService: PreviewHelper.HistoricalPriceService()
                )
            )
        )

        CoinView(
            store: .init(
                initialState: .init(
                    assetDetails: PreviewHelper.assetDetails(
                        tradeable: false
                    ),
                    kycStatus: .unverified,
                    accounts: []
                ),
                reducer: coinViewReducer,
                environment: .init(
                    kycStatusProvider: { .empty() },
                    accountsProvider: { .empty() },
                    historicalPriceService: PreviewHelper.HistoricalPriceService()
                )
            )
        )
    }
}
