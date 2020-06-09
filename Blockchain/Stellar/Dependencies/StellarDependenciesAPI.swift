//
//  StellarServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import StellarKit

protocol StellarDependenciesAPI {
    var accounts: StellarAccountAPI { get }
    var activity: ActivityItemEventServiceAPI { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> { get }
    var feeService: StellarFeeServiceAPI { get }
    var ledger: StellarLedgerAPI { get }
    var limits: StellarTradeLimitsAPI { get }
    var operation: StellarOperationsAPI { get }
    var prices: PriceServiceAPI { get }
    var repository: StellarWalletAccountRepositoryAPI { get }
    var transaction: StellarTransactionAPI { get }
    var walletActionEventBus: WalletActionEventBus { get }
}
