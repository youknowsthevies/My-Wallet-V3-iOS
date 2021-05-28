// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import ToolKit
import TransactionKit

final class TransactionAnalyticsHook {

    typealias SwapAnalyticsEvent = AnalyticsEvents.Swap
    typealias NewSwapAnalyticsEvent = AnalyticsEvents.New.Swap
    typealias NewSendAnalyticsEvent = AnalyticsEvents.New.Send
    typealias NewReceiveAnalyticsEvent = AnalyticsEvents.New.Receive

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

    func onFromAccountSelected(_ account: CryptoAccount, action: AssetAction) {
        switch action {
        case .swap:
            analyticsRecorder.record(events: [
                SwapAnalyticsEvent.fromAccountSelected,
                NewSwapAnalyticsEvent.swapFromSelected(inputCurrency: account.currencyType.code,
                                                       inputType: .init(account))
            ])
        case .send:
            analyticsRecorder.record(event:
                NewSendAnalyticsEvent.sendFromSelected(currency: account.currencyType.code, fromAccountType: .init(account))
            )
        case .receive:
            analyticsRecorder.record(event:
                NewReceiveAnalyticsEvent.receiveCurrencySelected(accountType: .init(account), currency: account.currencyType.code)
            )
        default:
            return
        }
    }

    func onReceiveAccountSelected(_ source: CurrencyType, target: CryptoAccount, action: AssetAction) {
        switch action {
        case .swap:
            analyticsRecorder.record(events: [
                SwapAnalyticsEvent.swapConfirmPair(asset: source, target: target.label),
                NewSwapAnalyticsEvent.swapReceiveSelected(outputCurrency: target.currencyType.code,
                                                          outputType: .init(target))
            ])
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

    func onMaxSelected(state: TransactionState) {
        switch state.action {
        case .swap:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount else {
                return
            }
            analyticsRecorder.record(events: [
                NewSwapAnalyticsEvent.swapAmountMaxClicked(amountCurrency: nil,
                                                           inputCurrency: source.currencyType.code,
                                                           inputType: .init(source),
                                                           outputCurrency: target.currencyType.code,
                                                           outputType: .init(target))
            ])
        case .send:
            guard let source = state.source as? CryptoAccount else {
                return
            }
            let target = state.destination as? CryptoAccount
            analyticsRecorder.record(event: NewSendAnalyticsEvent.sendAmountMaxClicked(currency: source.currencyType.code,
                                                                                       fromAccountType: .init(source),
                                                                                       toAccountType: .init(target)))
        default:
            return
        }

    }

    func onEnterAmountContinue(with state: TransactionState) {
        switch state.action {
        case .swap:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount,
                  let pair = state.sourceDestinationPair else {
                return
            }
            analyticsRecorder.record(events: [
                SwapAnalyticsEvent.enterAmountCtaClick(source: state.asset, target: target.label),
                NewSwapAnalyticsEvent.swapAmountEntered(inputAmount: state.amount.displayMajorValue.doubleValue,
                                                        inputCurrency: source.currencyType.code,
                                                        inputType: .init(source),
                                                        outputAmount: pair.quote.displayMajorValue.doubleValue *
                                                            state.amount.displayMajorValue.doubleValue,
                                                        outputCurrency: target.currencyType.code,
                                                        outputType: .init(target))
            ])
        default:
            return
        }
    }

    func onTransactionSuccess(with state: TransactionState) {
        switch state.action {
        case .swap:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount,
                  let pair = state.sourceDestinationPair else {
                return
            }
            let confirmations = state.pendingTransaction?.confirmations.compactMap { confirmation -> TransactionConfirmation.Model.NetworkFee? in
                if case let .networkFee(fee) = confirmation {
                    return fee
                } else {
                    return nil
                }
            }
            let networkFeeInputAmount = confirmations?.first(where: { $0.feeType == .withdrawalFee })?.fee.displayMajorValue.doubleValue ?? 0
            let networkFeeOutputAmount = confirmations?.first(where: { $0.feeType == .depositFee })?.fee.displayMajorValue.doubleValue ?? 0
            analyticsRecorder.record(events: [
                SwapAnalyticsEvent.transactionSuccess(asset: state.asset, source: state.asset.name, target: target.label),
                NewSwapAnalyticsEvent.swapRequested(exchangeRate: pair.quote.displayMajorValue.doubleValue,
                                                    inputAmount: state.amount.displayMajorValue.doubleValue,
                                                    inputCurrency: source.currencyType.code,
                                                    inputType: .init(source),
                                                    networkFeeInputAmount: networkFeeInputAmount,
                                                    networkFeeInputCurrency: source.currencyType.code,
                                                    networkFeeOutputAmount: networkFeeOutputAmount,
                                                    networkFeeOutputCurrency: target.currencyType.code,
                                                    outputAmount: pair.quote.displayMajorValue.doubleValue *
                                                        state.amount.displayMajorValue.doubleValue,
                                                    outputCurrency: target.currencyType.code,
                                                    outputType: .init(target))
            ])
        case .send:
            guard let target = state.destination as? CryptoAccount,
                  let source = state.source as? CryptoAccount else {
                return
            }
            analyticsRecorder.record(event:
                NewSendAnalyticsEvent.sendSubmitted(currency: target.currencyType.code,
                                                    feeRate: .init(state.feeSelection.selectedLevel),
                                                    fromAccountType: .init(source),
                                                    toAccountType: .init(target))
            )
        default:
            break
        }
    }

    func onTransactionFailure(with state: TransactionState) {
        let target = state.destination?.label
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.transactionFailed(asset: state.asset, target: target, source: state.asset.name))
        default:
            break
        }
    }

    func onConfirmationCtaClick(with state: TransactionState) {
        let target = state.destination!.label
        switch state.action {
        case .swap:
            analyticsRecorder.record(event: SwapAnalyticsEvent.swapConfirmCta(source: state.asset, target: target))
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
