//
//  WalletBalanceCellInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 5/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol WalletBalanceCellInteracting {
    var balanceViewInteractor: WalletBalanceViewInteractor { get }
}

final class WalletBalanceCellInteractor: WalletBalanceCellInteracting {
    
    let balanceViewInteractor: WalletBalanceViewInteractor
    
    init(balanceViewInteractor: WalletBalanceViewInteractor) {
        self.balanceViewInteractor = balanceViewInteractor
    }
}
