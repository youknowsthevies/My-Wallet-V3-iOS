// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import Localization
import PlatformKit
import RxSwift

final class InterestTransferTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Transfer.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state
            .map(weak: self) { (self, state) in
                switch state.executionStatus {
                case .inProgress,
                     .pending,
                     .notStarted:
                    return self.pending(state: state)
                case .completed:
                    return self.success(state: state)
                case .error:
                    return self.failed(state: state)
                }
            }
    }

    // MARK: - Private Functions

    private func success(state: TransactionState) -> PendingTransactionPageState {
        PendingTransactionPageState(
            title: String(
                format: LocalizationIds.Success.title,
                state.amount.displayString
            ),
            subtitle: String(
                format: LocalizationIds.Success.description,
                state.destination?.currencyType.code ?? ""
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "v-success-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .close,
            primaryButtonViewModel: .primary(with: LocalizationIds.Success.action)
        )
    }

    private func pending(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: String(format: LocalizationIds.Pending.title, state.amount.code),
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            )
        )
    }

    private func failed(state: TransactionState) -> PendingTransactionPageState {
        .init(
            title: state.transactionErrorTitle,
            subtitle: state.transactionErrorDescription,
            compositeViewType: .composite(
                .init(
                    baseViewType: .image(state.asset.logoResource),
                    sideViewAttributes: .init(
                        type: .image(.local(name: "circular-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .close,
            primaryButtonViewModel: .primary(with: LocalizationConstants.okString)
        )
    }
}
