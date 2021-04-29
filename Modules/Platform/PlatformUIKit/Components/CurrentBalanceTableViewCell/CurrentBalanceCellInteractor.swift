// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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
    
    public init(balanceFetching: AssetBalanceFetching,
                accountType: SingleAccountType) {
        self.assetBalanceViewInteractor = AssetBalanceTypeViewInteractor(
            assetBalanceFetching: balanceFetching,
            accountType: accountType
        )
    }
    
}
