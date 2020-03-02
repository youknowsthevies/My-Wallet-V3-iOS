//
//  SimpleBuyPaymentAccountClientAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
@testable import PlatformKit

class SimpleBuyPaymentAccountClientAPIMock: SimpleBuyPaymentAccountClientAPI {
    var mockResponse: SimpleBuyPaymentAccountResponse! = SimpleBuyPaymentAccountResponse.mock(with: .GBP, agent: .fullMock)
    func paymentAccount(for currency: FiatCurrency, token: String) -> Single<SimpleBuyPaymentAccountResponse> {
        return Single.just(mockResponse)
    }
}
