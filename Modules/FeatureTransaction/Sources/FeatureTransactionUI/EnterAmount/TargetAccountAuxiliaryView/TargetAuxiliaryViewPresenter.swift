// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import SwiftUI

final class TargetAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    private weak var delegate: AuxiliaryViewPresentingDelegate?
    private let transactionState: TransactionState

    init(delegate: AuxiliaryViewPresentingDelegate?, transactionState: TransactionState) {
        self.delegate = delegate
        self.transactionState = transactionState
    }

    func makeViewController() -> UIViewController {
        guard let account = transactionState.destination as? CryptoAccount else {
            fatalError("Impossible: a buy can only have a crypto destination and needs to have a fiat rate!")
        }

        guard let conversionRate = transactionState.sourceToFiatPair else {
            return UIHostingController(
                rootView: TargetAccountAuxiliaryView(
                    asset: account.asset,
                    price: .zero(currency: account.asset.currencyType),
                    action: { [weak self] in
                        self?.handleTap()
                    }
                )
                .redacted(reason: .placeholder)
            )
        }

        return UIHostingController(
            rootView: TargetAccountAuxiliaryView(
                asset: account.asset,
                price: conversionRate.quote,
                action: { [weak self] in
                    self?.handleTap()
                }
            )
        )
    }

    private func handleTap() {
        delegate?.auxiliaryViewTapped(self, state: transactionState)
    }
}
