//
//  OrderPriceTier.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct OrderPriceTier: Decodable {
    public let volume: String
    public let price: String
    public let marginPrice: String
}
