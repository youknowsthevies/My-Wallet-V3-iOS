//
//  StellarLedgerServiceMock.swift
//  StellarKitTests
//
//  Created by Paulo on 04/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit

final class StellarLedgerServiceMock: StellarLedgerServiceAPI {
    var fallbackBaseReserve: Decimal = 0
    var fallbackBaseFee: Decimal = 0
    var current: Observable<StellarLedger> = Observable.empty()
    var currentLedger: StellarLedger?
}
