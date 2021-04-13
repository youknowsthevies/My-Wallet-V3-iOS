//
//  PaymentEligibleMethodsClientAPI.swift
//  BuySellKit
//
//  Created by Dimitrios Chatzieleftheriou on 04/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol PaymentEligibleMethodsClientAPI: AnyObject {
    func eligiblePaymentMethods(for currency: String, onlyEligible: Bool) -> Single<[PaymentMethodsResponse.Method]>
}
