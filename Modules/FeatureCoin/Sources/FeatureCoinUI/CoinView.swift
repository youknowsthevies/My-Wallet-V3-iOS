// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import FeatureCoinDomain
import Localization
import SwiftUI
import ToolKit

public struct CoinViewState: Equatable {
    var assetDetails: AssetDetails?
    var kycStatus: KYCStatus?
    var hasAnyBalance: Bool? = false
    var isTradeable: Bool? = false

    var primaryAction: DoubleButtonAction? {
        if isTradeable == true {
            return .buy
        } else {
            return .send
        }
    }

    var seconaryAction: DoubleButtonAction? {
        switch (isTradeable, hasAnyBalance, (kycStatus ?? .noKyc) >= .gold) {
        case (true, true, true):
            return .sell
        default:
            return .receive
        }
    }
}

public enum CoinViewAction {
    case loadKycStatus
    case updateKycStatus(KYCStatus)
    case loadAssetDetails
    case updateAssetDetails(AssetDetails)
}

public struct CoinViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>
    let assetDetailsProvider: () -> AnyPublisher<AssetDetails, Never>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>,
        assetDetailsProvider: @escaping () -> AnyPublisher<AssetDetails, Never>
    ) {
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
        self.assetDetailsProvider = assetDetailsProvider
    }
}

public let coinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
> { state, action, environment in
    switch action {

    case .loadKycStatus:
        return environment.kycStatusProvider()
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map { kycStatus in
                .updateKycStatus(kycStatus)
            }

    case .updateKycStatus(kycStatus: let kycStatus):
        state.kycStatus = kycStatus
        return .none

    case .loadAssetDetails:
        return environment.assetDetailsProvider()
            .receive(on: environment.mainQueue)
            .eraseToEffect()
            .map { assetDetails in
                .updateAssetDetails(assetDetails)
            }

    case .updateAssetDetails(assetDetails: let assetDetails):
        state.assetDetails = assetDetails
        return .none
    }
}

public struct CoinView: View {

    let store: Store<CoinViewState, CoinViewAction>

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
    }

    typealias Localization = LocalizationConstants.Coin

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading) {
                PrimaryDivider()
                Text(
                    Localization.Label.Title.aboutCrypto
                        .interpolating(viewStore.assetDetails?.name ?? " ")
                )
                .typography(.body2)
                .padding()

                Text(viewStore.assetDetails?.about ?? " ")
                    .typography(.paragraph1)
                    .padding()

                if let url = viewStore.assetDetails?.url {
                    Link(Localization.Link.Title.visitWebsite, destination: url)
                        .typography(.paragraph2)
                        .padding()
                }

                DoubleButton(
                    primaryAction: viewStore.primaryAction,
                    secondaryAction: viewStore.seconaryAction
                ) { _ in
                    // TODO: Hook up the action
                }
            }
            .onAppear {
                viewStore.send(.loadKycStatus)
            }
        }
    }
}

// swiftlint:disable type_name
struct CoinView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationView {
            CoinView(
                store: .init(
                    initialState: .init(
                        assetDetails: .init(
                            name: "Bitcoin",
                            // swiftlint:disable line_length
                            about: "The world’s first cryptocurrency, Bitcoin is stored and exchanged securely on the internet through a digital ledger known as a blockchain. Bitcoins are divisible into smaller units known as satoshis — each satoshi is worth 0.00000001 bitcoin.",
                            url: URL(stringLiteral: "https://www.blockchain.com/")
                        ),
                        kycStatus: .gold
                    ),
                    reducer: coinViewReducer,
                    environment: .init(
                        kycStatusProvider: { .empty() },
                        assetDetailsProvider: { .empty() }
                    )
                )
            )
        }
    }
}
