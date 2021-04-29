// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import StellarKit

protocol StellarDependenciesAPI {
    var accounts: StellarAccountAPI { get }
    var feeService: AnyCryptoFeeService<StellarTransactionFee> { get }
    var ledger: StellarLedgerServiceAPI { get }
    var limits: StellarTradeLimitsAPI { get }
    var operation: StellarOperationsAPI { get }
    var prices: PriceServiceAPI { get }
    var repository: StellarWalletAccountRepositoryAPI { get }
    var transaction: StellarTransactionAPI { get }
    var walletActionEventBus: WalletActionEventBus { get }
}
