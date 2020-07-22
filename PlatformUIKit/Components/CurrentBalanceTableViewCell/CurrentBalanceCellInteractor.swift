//
//  CurrentBalanceCellInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol CurrentBalanceCellInteracting: AnyObject {
    var assetBalanceViewInteractor: AssetBalanceTypeViewInteracting { get }
    var balanceType: BalanceType { get }
}

public final class CurrentBalanceCellInteractor: CurrentBalanceCellInteracting {
    
    public let assetBalanceViewInteractor: AssetBalanceTypeViewInteracting
    
    public var balanceType: BalanceType {
        assetBalanceViewInteractor.balanceType
    }
    
    public init(balanceFetching: AssetBalanceFetching,
                balanceType: BalanceType) {
        self.assetBalanceViewInteractor = AssetBalanceTypeViewInteractor(
            assetBalanceFetching: balanceFetching,
            balanceType: balanceType
        )
    }
    
}
