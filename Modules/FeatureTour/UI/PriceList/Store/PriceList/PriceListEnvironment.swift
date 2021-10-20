// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineSchedulers
import DIKit
import Foundation
import PlatformKit

struct PriceListEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let enabledCurrenciesService: EnabledCurrenciesServiceAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.enabledCurrenciesService = enabledCurrenciesService
    }
}
