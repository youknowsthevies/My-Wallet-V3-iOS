//
//  CustodialServiceProvider.swift
//  Blockchain
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit
import PlatformKit

final class CustodialServiceProvider: CustodialServiceProviderAPI {
    
    static let `default`: CustodialServiceProviderAPI = CustodialServiceProvider()
    
    // MARK: - Properties

    let balance: CustodialBalanceServiceAPI
    let withdrawal: CustodyWithdrawalServiceAPI
        
    // MARK: - Setup
    
    init(authenticationService: NabuAuthenticationServiceAPI = NabuAuthenticationService.shared,
         client: CustodialClientAPI = CustodialClient()) {
        self.balance = CustodialBalanceService(
            client: client,
            authenticationService: authenticationService
        )
        self.withdrawal = CustodyWithdrawalRequestService(
            client: client,
            authenticationService: authenticationService
        )
    }
}

