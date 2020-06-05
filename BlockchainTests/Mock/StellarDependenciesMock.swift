//
//  StellarDependenciesMock.swift
//  BlockchainTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import PlatformKit
import StellarKit

class StellarDependenciesMock: StellarDependenciesAPI {
    var activity: ActivityItemEventFetcherAPI = ActivityItemEventFetcherMock()
    var activityDetails: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> = .init(api: StellarActivityItemEventDetailsFetcherAPIMock())
    var accounts: StellarAccountAPI = StellarAccountMock()
    var ledger: StellarLedgerAPI = StellarLedgerMock()
    var operation: StellarOperationsAPI = StellarOperationMock()
    var transaction: StellarTransactionAPI = StellarTransactionMock()
    var limits: StellarTradeLimitsAPI = StellarTradeLimitsMock()
    var repository: StellarWalletAccountRepositoryAPI = StellarWalletAccountRepositoryMock()
    var prices: PriceServiceAPI = PriceServiceMock()
    var walletActionEventBus: WalletActionEventBus = WalletActionEventBus()
    var feeService: StellarFeeServiceAPI = StellarFeeServiceMock()
}
