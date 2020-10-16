//
//  OrderQuote.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/13/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct OrderQuote: Decodable {
    public let pair: OrderPair
    public let priceTiers: [OrderPriceTier]
    
    enum CodingKeys: String, CodingKey {
        case pair = "currencyPair"
        case priceTiers
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        priceTiers = try values.decode([OrderPriceTier].self, forKey: .priceTiers)
        pair = try OrderPair(string: try values.decode(String.self, forKey: .pair))
    }
}
