//
//  BitcoinBalanceResponse.swift
//  BitcoinKit
//
//  Created by Jack Pooley on 10/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias BitcoinBalanceResponse = [String: BitcoinBalanceItemResponse]

struct BitcoinBalanceItemResponse: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case finalBalance = "final_balance"
        case nTx = "n_tx"
        case totalReceived = "total_received"
    }
    
    let finalBalance: Int
    
    let nTx: Int
    
    let totalReceived: Int
}
