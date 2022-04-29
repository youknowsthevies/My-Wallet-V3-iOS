// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureOpenBankingUI
import Localization
import PlatformUIKit
import RxSwift

/// Each `AssetAction` has a different pending screen. This includes
/// the success state as well as the transaction failed state.
protocol PendingTransactionStateProviding: AnyObject {
    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState>
}

extension PendingTransactionStateProviding {

    func bankingError(
        in state: TransactionState,
        error: OpenBanking.Error,
        icon: CompositeStatusViewType.Composite.BaseViewType
    ) -> PendingTransactionPageState {
        let ui = BankState.UI.errors[error, default: BankState.UI.defaultError]
        return .init(
            title: ui.info.title,
            subtitle: ui.info.subtitle,
            compositeViewType: .composite(
                .init(
                    baseViewType: icon,
                    sideViewAttributes: .init(
                        type: .image(.local(name: "circular-error-icon", bundle: .platformUIKit)),
                        position: .radiusDistanceFromCenter
                    ),
                    backgroundColor: .primaryButton,
                    cornerRadiusRatio: 0.5
                )
            ),
            effect: .close,
            primaryButtonViewModel: .primary(with: LocalizationConstants.okString),
            action: state.action,
            error: state.errorState
        )
    }
}
