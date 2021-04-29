// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AvailableTradingPairsResponse: Decodable {

    let pairs: [String]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        pairs = try container.decode([String].self)
    }
}
