// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol BitcoinChainHistoricalTransactionResponse: Decodable {

    func apply(latestBlockHeight: Int)
}

public struct BitcoinChainMultiAddressResponse<T: BitcoinChainHistoricalTransactionResponse>: Decodable {

    public let addresses: [BitcoinChainAddressResponse]
    public let transactions: [T]
    public let latestBlockHeight: Int

    enum RootCodingKeys: String, CodingKey {
        case addresses
        case txs
        case info
    }

    enum InfoCodingKeys: String, CodingKey {
        case latestBlock = "latest_block"
    }

    enum LatestBlockCodingKeys: String, CodingKey {
        case height
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: RootCodingKeys.self)
        let info = try values.nestedContainer(keyedBy: InfoCodingKeys.self, forKey: .info)
        let latestBlock = try info.nestedContainer(keyedBy: LatestBlockCodingKeys.self, forKey: .latestBlock)
        addresses = try values.decode([BitcoinChainAddressResponse].self, forKey: .addresses)
        latestBlockHeight = try latestBlock.decode(Int.self, forKey: .height)
        transactions = try values.decode([T].self, forKey: .txs)
        transactions.forEach { $0.apply(latestBlockHeight: latestBlockHeight) }
    }

    init(
        addresses: [BitcoinChainAddressResponse],
        transactions: [T],
        latestBlockHeight: Int
    ) {
        self.addresses = addresses
        self.transactions = transactions
        self.latestBlockHeight = latestBlockHeight
    }
}
