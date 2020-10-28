//
//  BlockchainAccount.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import ToolKit

public protocol BlockchainAccount {
    var id: String { get }

    var label: String { get }

    var balance: Single<MoneyValue> { get }
    
    var pendingBalance: Single<MoneyValue> { get }

    var actions: AvailableActions { get }

    var isFunded: Single<Bool> { get }

    var isCustodial: Bool { get }

    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>
}

extension BlockchainAccount {
    public var isCustodial: Bool {
        self is CryptoTradingAccount || self is CryptoInterestAccount
    }
}
