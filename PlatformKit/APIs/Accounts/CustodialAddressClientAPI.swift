//
//  CustodialAddressClientAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/18/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol CustodialPaymentAccountClientAPI {
    func custodialPaymentAccount(for cryptoCurrency: CryptoCurrency) -> Single<PaymentAccount.Response>
}
