//
//  CustodySendScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol WalletActionScreenInteracting: class {
    var balanceType: BalanceType { get }
    var currency: CryptoCurrency { get }
    var balanceFetching: AssetBalanceFetching { get }
    func refresh()
}

final class WalletActionScreenInteractor: WalletActionScreenInteracting {
    let balanceType: BalanceType
    let currency: CryptoCurrency
    let balanceFetching: AssetBalanceFetching
    
    // MARK: - Init
    
    init(balanceType: BalanceType,
         currency: CryptoCurrency,
         service: AssetBalanceFetching) {
        self.currency = currency
        self.balanceFetching = service
        self.balanceType = balanceType
    }
    
    func refresh() {
        balanceFetching.refresh()
    }
}
