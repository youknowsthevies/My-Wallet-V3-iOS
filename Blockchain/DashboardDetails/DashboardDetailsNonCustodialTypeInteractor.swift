//
//  DashboardDetailsNonCustodialTypeInteractor.swift
//  Blockchain
//
//  Created by Paulo on 10/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

final class DashboardDetailsNonCustodialTypeInteractor {

    var exists: Observable<Bool> {
        .just(currency.hasNonCustodialActivitySupport)
    }

    private let currency: CryptoCurrency

    init(currency: CryptoCurrency) {
        self.currency = currency
    }
}
