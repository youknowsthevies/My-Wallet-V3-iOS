// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import MoneyKit

public enum EVMNetwork: String, Hashable {
    case ethereum = "ETH"
    case polygon = "MATIC"

    public var chainID: BigUInt {
        switch self {
        case .ethereum:
            return 1
        case .polygon:
            return 137
        }
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
