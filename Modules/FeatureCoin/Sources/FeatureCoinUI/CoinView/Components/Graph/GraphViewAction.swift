// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureCoinDomain
import NetworkError

public enum GraphViewAction: BindableAction {
    case binding(_ action: BindingAction<GraphViewState>)
    case request(Series, force: Bool = false)
    case fetched(Result<GraphData, NetworkError>)
}
