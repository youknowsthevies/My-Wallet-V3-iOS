// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import ToolKit
import TransactionKit

final class TransactionAnalyticsHook {

    typealias SwapAnalyticsEvent = AnalyticsEvents.Swap

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }

    func onStepChanged(_ newState: TransactionState) {
        switch newState.action {
        case .swap:
            recordSwapScreenEvent(for: newState)
        default:
            break
        }
    }

    func onAccountSelected(_ account: CurrencyType, action: AssetAction) {
        switch action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.fromAccountSelected)
        default:
            return
        }
    }

    func onPairConfirmed(_ account: CurrencyType, target: TransactionTarget, action: AssetAction) {
        switch action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapConfirmPair(asset: account, target: target.label))
        default:
            return
        }
    }

    func onClose(action: AssetAction) {
        switch action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.cancelTransaction)
        default:
            return
        }
    }

    func onEnterAmountContinue(with state: TransactionState) {
        let sourceCurrency = state.source!.currencyType
        let target = state.destination!.label
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.enterAmountCtaClick(source: sourceCurrency, target: target))
        default:
            break
        }
    }

    func onTransactionSuccess(with state: TransactionState) {
        let sourceCurrency = state.source!.currencyType
        let target = state.destination!.label
        let asset = state.asset.currency
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.transactionSuccess(asset: asset, source: sourceCurrency.name, target: target))
        default:
            break
        }
    }

    func onTransactionFailure(with state: TransactionState) {
        let sourceCurrency = state.source?.currencyType
        let target = state.destination?.label
        let asset = state.asset.currency
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.transactionFailed(asset: asset, target: target, source: sourceCurrency?.name))
        default:
            break
        }
    }

    func onConfirmationCtaClick(with state: TransactionState) {
        let sourceCurrency = state.source!.currencyType
        let target = state.destination!.label
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapConfirmCta(source: sourceCurrency, target: target))
        default:
            break
        }
    }

    private func recordSwapScreenEvent(for state: TransactionState) {
        switch state.step {
        case .selectSource:
            analyticsRecorder.record(event: SwapAnalyticsEvent.fromPickerSeen)
        case .selectTarget:
            analyticsRecorder.record(event: SwapAnalyticsEvent.toPickerSeen)
        case .enterAddress:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapTargetAddressSheet)
        case .enterAmount:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapEnterAmount)
        case .confirmDetail:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapConfirmSeen)
        default:
            break
        }
    }
}
