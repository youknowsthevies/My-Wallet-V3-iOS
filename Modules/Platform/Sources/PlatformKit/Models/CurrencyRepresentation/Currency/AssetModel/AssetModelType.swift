// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A type of an `AssetModel`.
public enum AssetModelType: Hashable {

    /// A coin asset.
    case coin

    /// An Ethereum ERC-20 asset.
    case erc20

    /// A fiat asset.
    case fiat
}
