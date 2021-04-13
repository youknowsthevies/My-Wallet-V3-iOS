//
//  OrderFetchingClientAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 11/20/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol OrderFetchingClientAPI {
    func fetchTransaction(with transactionId: String) -> Single<SwapActivityItemEvent>
}
