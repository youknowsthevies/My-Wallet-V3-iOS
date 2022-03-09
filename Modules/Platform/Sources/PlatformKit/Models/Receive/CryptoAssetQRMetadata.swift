// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

/// Protocol definition for a URL payload for an asset. The URL typically contains the address,
/// as well as other metadata such as an amount, message, etc.
public protocol CryptoAssetQRMetadata {

    /// The address to which a on-chain transaction would be sent to .
    var address: String { get }

    /// The destination address to which a transaction would benefit.
    /// This may be same as `address` when the transaction will be sent to the recipient directly,
    ///  or this will be different when `address` is actually a contract that is brokering the transaction (eg ERC-20 transfers).
    var destinationAddress: String { get }

    var amount: CryptoValue? { get }

    /// Converts this URL to an absolute string (e.g. "bitcoin:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    var absoluteString: String { get }

    /// Render the `absoluteString` with the scheme prefix
    var includeScheme: Bool { get }
}

extension CryptoAssetQRMetadata {
    public var destinationAddress: String {
        address
    }
}
