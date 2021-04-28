//
//  WithdrawRouterInteractor.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import BuySellKit
import DIKit
import RIBs
import ToolKit

protocol WithdrawFlowRouting: AnyObject {
    func routeToFlowRoot()
    func routeToBankSelected(beneficiary: Beneficiary)
    func routeToCheckout(checkoutData: WithdrawalCheckoutData)
    func didTapBack()
    /// Indicates a request for the dismissal of the flow
    func closeFlow()
}

protocol WithdrawFlowListener: AnyObject {

}

public final class WithdrawRootInteractor: Interactor,
                                           WithdrawFlowInteractable,
                                           WithdrawFlowListener,
                                           LinkedBanksSelectionListener,
                                           WithdrawAmountPageListener {

    private typealias AnalyticsEvent = AnalyticsEvents.FiatWithdrawal

    weak var router: WithdrawFlowRouting?
    weak var listener: WithdrawFlowListener?

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }
    
    public override func didBecomeActive() {
        super.didBecomeActive()
        startFlow()
    }

    // MARK: - SelectLinkedBanksListener
    func bankSelected(beneficiary: Beneficiary) {
        router?.routeToBankSelected(beneficiary: beneficiary)
    }

    // MARK: - SelectLinkedBanksListener

    func enterAmountDidTapBack() {
        router?.didTapBack()
    }

    func linkedBankedDidTapBack() {
        router?.didTapBack()
    }

    // MARK: - WithdrawAmountPageListener

    func showCheckoutScreen(checkoutData: WithdrawalCheckoutData) {
        router?.routeToCheckout(checkoutData: checkoutData)
    }

    func checkoutDidTapBack() {
        router?.didTapBack()
    }

    // MARK: - Private methods
    private func startFlow() {
        analyticsRecorder.record(event: AnalyticsEvents.FiatWithdrawal.formShown)
        router?.routeToFlowRoot()
    }

    func closeFlow() {
        router?.closeFlow()
    }
}
