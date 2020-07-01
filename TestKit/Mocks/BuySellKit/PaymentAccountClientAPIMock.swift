//
//  SimpleBuyPaymentAccountClientAPIMock.swift
//  PlatformKitTests
//
//  Created by Paulo on 07/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import BuySellKit
@testable import PlatformKit
import RxSwift

class SimpleBuyPaymentAccountClientAPIMock: PaymentAccountClientAPI {
    var mockResponse: PaymentAccountResponse! = PaymentAccountResponse.mock(with: .GBP, agent: .fullMock)
    func paymentAccount(for currency: FiatCurrency, token: String) -> Single<PaymentAccountResponse> {
        Single.just(mockResponse)
    }
}
