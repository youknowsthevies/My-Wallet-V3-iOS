//
//  CustodialQuoteAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol CustodialQuoteAPI {
    func fetchQuoteResponse(with request: OrderQuoteRequest) -> Single<OrderQuoteResponse>
}
