import ComposableArchitecture
import DIKit
import FeatureTransactionUI

struct BuyButtonEnvironment {
    let walletOperationsRouter: WalletOperationsRouting

    init(
        walletOperationsRouter: WalletOperationsRouting = resolve()
    ) {
        self.walletOperationsRouter = walletOperationsRouter
    }
}

extension BuyButtonEnvironment {
    static let `default`: BuyButtonEnvironment = .init(
        walletOperationsRouter: resolve()
    )
}
