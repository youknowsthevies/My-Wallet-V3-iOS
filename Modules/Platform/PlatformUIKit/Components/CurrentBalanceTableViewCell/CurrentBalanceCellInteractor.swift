// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

public protocol CurrentBalanceCellInteracting: AnyObject {
    var assetBalanceViewInteractor: AssetBalanceTypeViewInteracting { get }
    var accountType: SingleAccountType { get }
}

public final class CurrentBalanceCellInteractor: CurrentBalanceCellInteracting {

    public let assetBalanceViewInteractor: AssetBalanceTypeViewInteracting

    public var accountType: SingleAccountType {
        assetBalanceViewInteractor.accountType
    }

    public init(account: BlockchainAccount) {
        assetBalanceViewInteractor = AccountBalanceTypeViewInteractor(
            account: account
        )
    }

    public init(balanceFetching: AssetBalanceFetching,
                accountType: SingleAccountType) {
        assetBalanceViewInteractor = AssetBalanceTypeViewInteractor(
            assetBalanceFetching: balanceFetching,
            accountType: accountType
        )
    }
}
