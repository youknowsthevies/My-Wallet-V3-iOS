//
//  ERC20TransfersResponse.swift
//  ERC20Kit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ERC20TransfersResponse<Token: ERC20Token>: Decodable {

    let transactions: [ERC20HistoricalTransaction<Token>]

    // MARK: Decodable

    private enum CodingKeys: String, CodingKey {
        case transactions = "transfers"
    }
}
