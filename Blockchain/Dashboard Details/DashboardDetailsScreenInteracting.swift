//
//  DashboardDetailsScreenInteracting.swift
//  Blockchain
//
//  Created by AlexM on 11/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol DashboardDetailsScreenInteracting: class {
    var currency: CryptoCurrency { get }
    
    var priceServiceAPI: HistoricalFiatPriceServiceAPI { get }
    
    var recoveryPhraseStatus: RecoveryPhraseStatusProviding { get }
    
    var recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI { get }
    
    var balanceFetching: AssetBalanceFetching { get }
    
    func refresh()
}
