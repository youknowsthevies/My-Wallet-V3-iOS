//
//  EthereumHistoricalTransactionResponse.swift
//  EthereumKit
//
//  Created by Jack on 19/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt

struct EthereumAccountTransactionsResponse: Codable {
    let transactions: [EthereumHistoricalTransactionResponse]
    let page: String
    let size: Int
}

public struct EthereumHistoricalTransactionResponse: Codable {
    public enum State: String, CaseIterable, Codable {
        case confirmed = "CONFIRMED"
        case pending = "PENDING"
        case replaced = "REPLACED"
    }

    public var createdAt: Date {
        guard let timeInterval = timestamp.flatMap({ TimeInterval($0) }) else {
            return Date()
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    public let blockNumber: String?
    public let from: String
    public let gasPrice: String
    public let gasUsed: String?
    public let hash: String
    public let state: State
    public let to: String
    public let value: String
    private let timestamp: String?
}
