//
//  CustodialServiceProvider.swift
//  Blockchain
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import ToolKit

final class CustodialServiceProvider: CustodialServiceProviderAPI {
    
    static let `default`: CustodialServiceProviderAPI = CustodialServiceProvider()
    
    // MARK: - Properties

    let balance: TradingBalanceServiceAPI
    let withdrawal: CustodyWithdrawalServiceAPI
        
    // MARK: - Setup
    
    init() {
        self.balance = TradingBalanceService()
        self.withdrawal = CustodyWithdrawalRequestService()
    }
}

