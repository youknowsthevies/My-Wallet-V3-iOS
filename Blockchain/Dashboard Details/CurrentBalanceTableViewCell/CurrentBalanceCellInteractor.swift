//
//  CurrentBalanceCellInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit

final class CurrentBalanceCellInteractor {
    
    let assetBalanceViewInteractor: AssetBalanceTypeViewInteractor
    
    var balanceType: BalanceType {
        assetBalanceViewInteractor.balanceType
    }
    
    init(balanceFetching: AssetBalanceFetching,
         balanceType: BalanceType) {
        self.assetBalanceViewInteractor = .init(
            assetBalanceFetching: balanceFetching,
            balanceType: balanceType
        )
    }
    
}
