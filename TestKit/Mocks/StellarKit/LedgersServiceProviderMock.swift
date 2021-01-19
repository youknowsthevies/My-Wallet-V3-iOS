//
//  LedgersServiceProviderMock.swift
//  StellarKitTests
//
//  Created by Paulo on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
@testable import StellarKit

final class LedgersServiceProviderMock: LedgersServiceProviderAPI {
    
    var underlyingLedgersService: LedgersServiceAPI!
    
    var ledgersService: Single<LedgersServiceAPI> {
        .just(underlyingLedgersService)
    }
    
    init(ledgersService: LedgersServiceAPI) {
        underlyingLedgersService = ledgersService
    }
}
