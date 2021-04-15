//
//  OrderCreationService.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/16/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol OrderCreationServiceAPI {
    func createOrder(direction: OrderDirection,
                     quoteIdentifier: String,
                     volume: MoneyValue,
                     destinationAddress: String?,
                     refundAddress: String?) -> Single<SwapOrder>
}

final class OrderCreationService: OrderCreationServiceAPI {
    
    // MARK: - Service Error
    
    enum ServiceError: Error {
        case mappingError
    }
    
    // MARK: - Properties
    
    private let client: OrderCreationClientAPI
    
    // MARK: - Setup
    
    init(client: OrderCreationClientAPI = resolve()) {
        self.client = client
    }
    
    // MARK: - OrderCreationServiceAPI
    
    public func createOrder(direction: OrderDirection,
                            quoteIdentifier: String,
                            volume: MoneyValue,
                            destinationAddress: String?,
                            refundAddress: String?) -> Single<SwapOrder> {
        let request = OrderCreationRequest(
            direction: direction,
            quoteId: quoteIdentifier,
            volume: volume,
            destinationAddress: destinationAddress,
            refundAddress: refundAddress
        )
        return client
            .create(with: request)
            .map { SwapOrder(identifier: $0.identifier, state: $0.status, depositAddress: $0.kind.depositAddress) }
    }
}

protocol OrderUpdateServiceAPI {
    func updateOrder(identifier: String,
                     success: Bool) -> Completable
}

final class OrderUpdateService: OrderUpdateServiceAPI {

    // MARK: - Properties

    private let client: OrderUpdateClientAPI

    // MARK: - Setup

    init(client: OrderUpdateClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderCreationServiceAPI
    
    public func updateOrder(identifier: String,
                            success: Bool) -> Completable {
        client
            .updateOrder(with: identifier, updateRequest: OrderUpdateRequest(success: success))
    }
}
