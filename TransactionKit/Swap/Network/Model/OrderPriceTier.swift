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
    
    public init(volume: String, price: String, marginPrice: String) {
        self.volume = volume
        self.price = price
        self.marginPrice = marginPrice
    }
}

public extension OrderPriceTier {
    static let zero = OrderPriceTier(volume: "0", price: "0", marginPrice: "0")
}
