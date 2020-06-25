//
//  TotalBalanceViewInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxRelay
import RxSwift

final class TotalBalanceViewInteractor {
    
    typealias InteractionState = DashboardAsset.State.AssetPrice.Interaction
    
    // MARK: - Exposed Properties
    
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Injected
    
    private let chartInteractor: AssetPieChartInteracting
    private let balanceInteractor: AssetPriceViewInteracting
    
    // MARK: - Accessors
    
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    
    // MARK: - Setup
    
    init(chartInteractor: AssetPieChartInteracting,
         balanceInteractor: AssetPriceViewInteracting) {
        self.chartInteractor = chartInteractor
        self.balanceInteractor = balanceInteractor
    }
}
