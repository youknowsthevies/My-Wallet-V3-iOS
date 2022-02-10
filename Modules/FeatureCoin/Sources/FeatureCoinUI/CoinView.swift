// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureCoinDomain
import SwiftUI
import ToolKit

public struct CoinViewState: Equatable {
    var kycStatus: KYCStatus?
    var primaryAction: DoubleButtonAction? {
        switch kycStatus {
        case .noKyc:
            return .send
        case .silver,
             .gold:
            return .buy
        case .none:
            return nil
        }
    }

    var seconaryAction: DoubleButtonAction? {
        switch kycStatus {
        case .noKyc,
             .silver:
            return .receive
        case .gold:
            return .sell
        case .none:
            return nil
        }
    }
}

public enum CoinViewAction {
    case loadKycStatus
    case updateKycStatus(kycStatus: KYCStatus)
}

public struct CoinViewEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let kycStatusProvider: () -> AnyPublisher<KYCStatus, Never>

    public init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        kycStatusProvider: @escaping () -> AnyPublisher<KYCStatus, Never>
    ) {
        self.mainQueue = mainQueue
        self.kycStatusProvider = kycStatusProvider
    }
}

public let coinViewReducer = Reducer<
    CoinViewState,
    CoinViewAction,
    CoinViewEnvironment
> { state, action, environment in
    switch action {

    case .loadKycStatus:
        return .merge(
            environment.kycStatusProvider()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { kycStatus in
                    .updateKycStatus(kycStatus: kycStatus)
                }
        )

    case .updateKycStatus(kycStatus: let kycStatus):
        state.kycStatus = kycStatus
        return .none
    }
}

public struct CoinView: View {

    let store: Store<CoinViewState, CoinViewAction>

    public init(store: Store<CoinViewState, CoinViewAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
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
        NavigationView {
            CoinView(
                store: .init(
                    initialState: .init(),
                    reducer: coinViewReducer,
                    environment: .init(
                        kycStatusProvider: {
                            .just(.gold)
                        }
                    )
                )
            )
        }
    }
}
