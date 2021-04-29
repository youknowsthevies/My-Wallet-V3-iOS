// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

public protocol DepositRootRouting: ViewableRouting {
    /// Routes to the `Select a Funding Method` screen
    func routeToDepositLanding()
    
    /// Routes to the TransactonFlow with a given `FiatAccount`
    func routeToDeposit(sourceAccount: FiatAccount)
    
    /// Exits the TransactonFlow
    func dismissTransactionFlow()
}

protocol DepositRootListener: ViewListener { }

final class DepositRootInteractor: Interactor, DepositRootInteractable, DepositRootListener {

    weak var router: DepositRootRouting?
    weak var listener: DepositRootListener?

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
    
    func routeToWireTransfer() {
        unimplemented()
    }
    
    func routeToLinkedBanks() {
        unimplemented()
    }
    
    func routeToAddABank() {
        unimplemented()
    }
    
    func routeToTransactionFlow(sourceAccount: LinkedBankAccount) {
        unimplemented()
    }
    
    func presentKYCTiersScreen() {
        unimplemented()
    }
    
    func dismissTransactionFlow() {
        unimplemented()
    }
    
    private lazy var routeViewDidAppear: Void = {
        router?.routeToDepositLanding()
    }()
    
    func viewDidAppear() {
        // if first time, got to variant router
        _ = routeViewDidAppear
    }
}
