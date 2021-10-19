// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import RIBs

protocol BuyFlowBuildable: Buildable {
    func build(with listener: BuyFlowListening, interactor: BuyFlowInteractor) -> BuyFlowRouting
}

final class BuyFlowBuilder: BuyFlowBuildable {

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI) {
        self.analyticsRecorder = analyticsRecorder
    }

    func build(with listener: BuyFlowListening, interactor: BuyFlowInteractor) -> BuyFlowRouting {
        let router = BuyFlowRouter(interactor: interactor, analyticsRecorder: analyticsRecorder)
        interactor.listener = listener
        interactor.router = router
        return router
    }
}
