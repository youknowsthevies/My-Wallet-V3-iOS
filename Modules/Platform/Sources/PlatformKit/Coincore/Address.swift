// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ReceiveAddress: TransactionTarget {
    var address: String { get }
    var memo: String? { get }
}

extension ReceiveAddress {
    public var memo: String? {
        nil
    }
}

/// A TransactionTarget that disallows changing its details (e.g. amount, target)
public protocol StaticTransactionTarget: TransactionTarget {}

/// A Wallet Connect Transaction Target.
public protocol WalletConnectTarget: StaticTransactionTarget {}

public protocol CryptoReceiveAddress: ReceiveAddress, CryptoTarget {}

public protocol CryptoAssetQRMetadataProviding {
    var metadata: CryptoAssetQRMetadata { get }
}

public enum ReceiveAddressError: Error {
    case notSupported
}
