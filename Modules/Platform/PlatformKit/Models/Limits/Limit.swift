//
//  Limit.swift
//  PlatformKit
//
//  Created by Alex McGregor on 9/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

public struct Limit: Decodable {
    public let limit: Decimal
    public let available: Decimal
    public let used: Decimal

    enum CodingKeys: String, CodingKey {
        case limit
        case available
        case used
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        limit = try values.decodeIfPresentDecimalFromString(forKey: .limit) ?? 0
        available = try values.decodeIfPresentDecimalFromString(forKey: .available) ?? 0
        used = try values.decodeIfPresentDecimalFromString(forKey: .used) ?? 0
    }
}
