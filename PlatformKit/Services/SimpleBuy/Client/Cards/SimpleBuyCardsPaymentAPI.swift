//
//  SimpleBuyCardsPaymentAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyCardsPaymentAPI {
    func fetchPaymentDetails(token: String, beneficiaryID: String, paymentID: String) -> Single<SimpleBuyCreditCardPayment>
    
    // TODO: Docs state that you receive an EveryPay link from this endpoint
    func send(token: String, beneficiaryID: String, paymentSubmission: SimpleBuyCreditCardPaymentSubmission) -> Single<URL>
}
