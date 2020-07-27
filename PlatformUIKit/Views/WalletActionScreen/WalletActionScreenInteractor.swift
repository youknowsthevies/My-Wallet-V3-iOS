//
//  CustodySendScreenInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol WalletActionScreenInteracting: class {
    var currency: CurrencyType { get }
    var balanceType: BalanceType { get }
    var supportsSend: Bool { get }
    var supportsSwap: Bool { get }
    var supportsActivity: Bool { get }
    var balanceCellInteractor: CurrentBalanceCellInteracting { get }
}

public final class WalletActionScreenInteractor: WalletActionScreenInteracting {
    public let balanceType: BalanceType
    public let currency: CurrencyType
    public let balanceCellInteractor: CurrentBalanceCellInteracting
    public var supportsSend: Bool = false
    public var supportsSwap: Bool = false
    public var supportsActivity: Bool = false
    
    // MARK: - Init
    
    public init(balanceType: BalanceType,
                currency: CurrencyType,
                service: AssetBalanceFetching) {
        self.currency = currency
        self.balanceType = balanceType
        self.balanceCellInteractor = CurrentBalanceCellInteractor(
            balanceFetching: service,
            balanceType: balanceType
        )
        switch currency {
        case .crypto(let crypto):
            supportsSend = crypto.hasNonCustodialWithdrawalSupport
            supportsActivity = crypto.hasNonCustodialActivitySupport
            supportsSwap = crypto.hasNonCustodialTradeSupport
        case .fiat:
            break
        }
    }
}
