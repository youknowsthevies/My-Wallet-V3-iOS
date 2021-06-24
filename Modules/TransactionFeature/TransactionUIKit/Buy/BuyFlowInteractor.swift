// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

final class BuyFlowInteractor: Interactor {

    var listener: BuyFlowListening?
    weak var router: BuyFlowRouting?
}

extension BuyFlowInteractor: TransactionFlowListener {

    func presentKYCTiersScreen() {
        // TODO: do I even need this?
    }

    func dismissTransactionFlow() {
        // TODO: can I make this also return completed?
        listener?.buyFlowDidComplete(with: .abandoned)
    }
}
