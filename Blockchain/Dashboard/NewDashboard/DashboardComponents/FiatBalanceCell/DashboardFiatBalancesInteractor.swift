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
import BuySellUIKit

final class DashboardFiatBalancesInteractor {
    
    var shouldAppear: Observable<Bool> {
        fiatBalanceCollectionViewInteractor.interactorsState
            .compactMap { $0.value }
            .map { $0.count > 0 }
            .catchErrorJustReturn(false)
    }
    
    let fiatBalanceCollectionViewInteractor: FiatBalanceCollectionViewInteractor
        
    // MARK: - Setup
    
    init(balanceProvider: BalanceProviding,
         featureFetcher: FeatureFetching,
         paymentMethodsService: PaymentMethodsServiceAPI,
         enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        fiatBalanceCollectionViewInteractor = FiatBalanceCollectionViewInteractor(
            balanceProvider: balanceProvider,
            enabledCurrenciesService: enabledCurrenciesService,
            paymentMethodsService: paymentMethodsService,
            featureFetcher: featureFetcher
        )
    }
    
    func refresh() {
        fiatBalanceCollectionViewInteractor.refresh()
    }
}
