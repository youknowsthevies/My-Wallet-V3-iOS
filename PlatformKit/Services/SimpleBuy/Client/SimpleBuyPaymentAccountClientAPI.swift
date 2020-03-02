//
//  SimpleBuyPaymentAccountClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyPaymentAccountClientAPI: class {

    /// Fetch the Payment Account information for the given currency.
    func paymentAccount(for currency: FiatCurrency, token: String) -> Single<SimpleBuyPaymentAccountResponse>
}
