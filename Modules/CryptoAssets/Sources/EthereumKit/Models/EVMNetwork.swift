// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit

public enum EVMNetwork: String, Hashable, CaseIterable {
    case ethereum = "ETH"
    case polygon = "MATIC"

    public var name: String {
        switch self {
        case .ethereum:
            return "Ethereum"
        case .polygon:
            return "Polygon"
        }
    }

    public var chainID: BigUInt {
        switch self {
        case .ethereum:
            return 1
        case .polygon:
            return 137
        }
    }

    public init?(chainID: BigUInt) {
        guard let match = EVMNetwork.allCases.first(where: { $0.chainID == chainID }) else {
            return nil
        }
        self = match
    }

    public var assetModel: AssetModel {
        switch self {
        case .ethereum:
            return .ethereum
        case .polygon:
            return .polygon
        }
    }

    public var cryptoCurrency: CryptoCurrency {
        switch self {
        case .ethereum:
            return .ethereum
        case .polygon:
            return .polygon
        }
    }
}

extension AssetModel {

    public var evmNetwork: EVMNetwork? {
        switch self {
        case .ethereum:
            return .ethereum
        case .polygon:
            return .polygon
        default:
            return kind.evmNetwork
        }
    }
}

extension AssetModelType {

    fileprivate var evmNetwork: EVMNetwork? {
        switch self {
        case .celoToken,
             .coin,
             .fiat:
            return nil
        case .erc20(_, let parentChain):
            return parentChain.evmNetwork
        }
    }
}

extension AssetModelType.ERC20ParentChain {

    public var evmNetwork: EVMNetwork {
        switch self {
        case .ethereum:
            return .ethereum
        case .polygon:
            return .polygon
        }
    }
}
