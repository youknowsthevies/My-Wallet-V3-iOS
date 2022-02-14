// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import RxSwift

public struct BitcoinChainReceiveAddress<Token: BitcoinChainToken>: CryptoReceiveAddress,
    CryptoAssetQRMetadataProviding
{

    public let address: String
    public let asset: CryptoCurrency
    public let bip21URI: BIP21URI<Token>
    public let label: String
    public let onTxCompleted: TxCompleted

    public var metadata: CryptoAssetQRMetadata {
        bip21URI
    }

    public init(
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        asset = Token.coin.cryptoCurrency
        bip21URI = BIP21URI<Token>(address: address, amount: nil, includeScheme: true)
        self.address = address
        self.label = label
        self.onTxCompleted = onTxCompleted
    }

    public init(
        bip21URI: BIP21URI<Token>,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) {
        asset = Token.coin.cryptoCurrency
        address = bip21URI.address
        self.bip21URI = bip21URI
        self.label = label
        self.onTxCompleted = onTxCompleted
    }
}
