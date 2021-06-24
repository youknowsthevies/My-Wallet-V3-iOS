// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum CryptoAssetType: Hashable {
    case erc20(contract: String, logoPNGUrl: String)
    case coin
}

public protocol CryptoAssetModel: Hashable {
    var name: String { get }
    var code: String { get }
    var maxDecimalPlaces: Int { get }
    var maxStartDate: TimeInterval { get }
    var kind: CryptoAssetType { get }
}

extension CryptoAssetModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }
}
