// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ERC20TransfersResponse<Token: ERC20Token>: Decodable {

    let transactions: [ERC20HistoricalTransaction<Token>]

    // MARK: Decodable

    private enum CodingKeys: String, CodingKey {
        case transactions = "transfers"
    }
}
