// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol WalletActionScreenInteracting: AnyObject {
    var currency: CurrencyType { get }
    var accountType: SingleAccountType { get }
    var balanceCellInteractor: CurrentBalanceCellInteracting { get }
}

public final class WalletActionScreenInteractor: WalletActionScreenInteracting {
    public var accountType: SingleAccountType {
        balanceCellInteractor.accountType
    }
    public let currency: CurrencyType
    public let balanceCellInteractor: CurrentBalanceCellInteracting

    // MARK: - Init

    public init(account: BlockchainAccount) {
        currency = account.currencyType
        self.balanceCellInteractor = CurrentBalanceCellInteractor(
            account: account
        )
    }
}
