// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol PaymentMethodRouting: ViewableRouting { }

protocol PaymentMethodListener: class {
    /// Routes to the `Linked Banks` screen
    func routeToLinkedBanks()

    /// Routes to the `Add [FiatCurrency] Wire Transfer` screen
    func routeToWireTransfer()
}

final class PaymentMethodInteractor: Interactor, PaymentMethodInteractable {

    weak var router: PaymentMethodRouting?
    weak var listener: PaymentMethodListener?

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
