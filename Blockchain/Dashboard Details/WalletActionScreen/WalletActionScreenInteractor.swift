//
//  CustodySendScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol WalletActionScreenInteracting: class {
    var currency: CryptoCurrency { get }
    var balanceType: BalanceType { get }
    var balanceCellInteractor: CurrentBalanceCellInteractor { get }
}

final class WalletActionScreenInteractor: WalletActionScreenInteracting {
    let balanceType: BalanceType
    let currency: CryptoCurrency
    let balanceCellInteractor: CurrentBalanceCellInteractor
    
    // MARK: - Init
    
    init(balanceType: BalanceType,
         currency: CryptoCurrency,
         service: AssetBalanceFetching) {
        self.currency = currency
        self.balanceType = balanceType
        self.balanceCellInteractor = .init(
            balanceFetching: service,
            balanceType: balanceType
        )
    }
}
