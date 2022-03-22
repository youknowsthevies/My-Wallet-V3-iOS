// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureCoinDomain
import Foundation
import NetworkError

public struct GraphViewState: Equatable {

    @BindableState var selected: Int?
    var interval: Series = .now

    var result: Result<GraphData, NetworkError>?
    var isFetching: Bool = false

    var tolerance: Int = 2
    var density: Int = 250
    var date = Date()
}
