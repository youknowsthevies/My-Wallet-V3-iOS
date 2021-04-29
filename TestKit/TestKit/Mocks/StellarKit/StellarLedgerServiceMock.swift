// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import StellarKit

final class StellarLedgerServiceMock: StellarLedgerServiceAPI {
    var fallbackBaseReserve: Decimal = 0
    var fallbackBaseFee: Decimal = 0
    var current: Observable<StellarLedger> = Observable.empty()
    var currentLedger: StellarLedger?
}
