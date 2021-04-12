//
//  PaymentAccountClientAPI.swift
//  PlatformKit
//
//  Created by Paulo on 03/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol PaymentAccountClientAPI: class {

    /// Fetch the Payment Account information for the given currency.
    func paymentAccount(for currency: FiatCurrency) -> Single<PlatformKit.PaymentAccount.Response>
}
