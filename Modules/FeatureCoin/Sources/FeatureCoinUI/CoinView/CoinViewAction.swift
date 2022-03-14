// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions
import FeatureCoinDomain
import NetworkError

public enum CoinViewAction: BlockchainNamespaceObservationAction, BindableAction {
    case onAppear, onDisappear
    case update(Result<(KYCStatus, [Account.Snapshot]), Error>)
    case fetchedInterestRate(Result<Double, NetworkError>)
    case reset
    case graph(GraphViewAction)
    case observation(BlockchainNamespaceObservation)
    case binding(BindingAction<CoinViewState>)
}
