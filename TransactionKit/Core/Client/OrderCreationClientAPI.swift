//
//  OrderCreationClientAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

protocol OrderCreationClientAPI {
    func create(with orderRequest: OrderCreationRequest) -> Single<SwapActivityItemEvent>
}

protocol OrderUpdateClientAPI {
    func updateOrder(with transactionId: String, updateRequest: OrderUpdateRequest) -> Completable
}
