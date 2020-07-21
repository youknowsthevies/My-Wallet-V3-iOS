//
//  DashboardFiatBalancesInteractor.swift
//  Blockchain
//
//  Created by Daniel on 14/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import PlatformUIKit
import BuySellKit

final class DashboardFiatBalancesInteractor {
    
    var shouldAppear: Single<Bool> {
        fiatBalanceCollectionViewInteractor.interactorsState
            .compactMap { $0.value }
            .map { $0.count > 0 }
            .take(1)
            .asSingle()
            .catchErrorJustReturn(false)
    }
    
    let fiatBalanceCollectionViewInteractor: FiatBalanceCollectionViewInteractor
        
    // MARK: - Setup
    
    init(balanceProvider: BalanceProviding) {
        fiatBalanceCollectionViewInteractor = FiatBalanceCollectionViewInteractor(
            balanceProvider: balanceProvider
        )
    }
}
