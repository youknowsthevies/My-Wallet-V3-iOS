//
//  CustodialServiceProviderAPI.swift
//  Blockchain
//
//  Created by AlexM on 2/19/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

protocol CustodialServiceProviderAPI: class {
    var withdrawal: CustodyWithdrawalServiceAPI { get }
    var balance: CustodialBalanceServiceAPI { get }
}
