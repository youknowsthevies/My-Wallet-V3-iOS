// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import Errors
import FeatureCoinDomain

public enum GraphViewAction: BindableAction {
    case onAppear(Tag.Context)
    case binding(_ action: BindingAction<GraphViewState>)
    case request(Series, force: Bool = false)
    case fetched(Result<GraphData, NetworkError>)
}
