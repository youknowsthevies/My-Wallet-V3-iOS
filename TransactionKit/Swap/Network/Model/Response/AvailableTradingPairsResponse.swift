//
//  AvailableTradingPairsResponse.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct AvailableTradingPairsResponse: Decodable {

    let pairs: [String]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        pairs = try container.decode([String].self)
    }
}
