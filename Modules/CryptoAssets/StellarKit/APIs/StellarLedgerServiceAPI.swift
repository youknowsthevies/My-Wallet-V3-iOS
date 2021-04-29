// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// This is not included in `PlatformKit` as no other currency has the concept of a ledger.
/// That being said, the fees for XLM supposedly don't change. We only use
/// the ledger to derive the fee.
public protocol StellarLedgerServiceAPI {
    var fallbackBaseReserve: Decimal { get }
    var fallbackBaseFee: Decimal { get }
    
    var current: Observable<StellarLedger> { get }
    var currentLedger: StellarLedger? { get }
}
