// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
import StellarKit

class StellarDependenciesMock: StellarDependenciesAPI {

    var activity: ActivityItemEventServiceAPI = ActivityItemEventFetcherMock()
    var activityDetails: AnyActivityItemEventDetailsFetcher<StellarActivityItemEventDetails> = .init(api: StellarActivityItemEventDetailsFetcherAPIMock())
    var accounts: StellarAccountAPI = StellarAccountMock()
    var ledger: StellarLedgerServiceAPI = StellarLedgerServiceMock()
    var operation: StellarOperationsAPI = StellarOperationMock()
    var transaction: StellarTransactionAPI = StellarTransactionMock()
    var limits: StellarTradeLimitsAPI = StellarTradeLimitsMock()
    var repository: StellarWalletAccountRepositoryAPI = StellarWalletAccountRepositoryMock()
    var prices: PriceServiceAPI = PriceServiceMock()
    var walletActionEventBus: WalletActionEventBus = WalletActionEventBus()
    var feeService: AnyCryptoFeeService<StellarTransactionFee> {
        AnyCryptoFeeService(service: feeServiceMock)
    }

    var feeServiceMock: CryptoFeeServiceMock<StellarTransactionFee> = CryptoFeeServiceMock()
}
