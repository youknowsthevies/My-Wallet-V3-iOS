// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit

enum DeserializeMetadataNodeError: Error {
    case failedToDeserializePrivateKey(Error)
}

func deserializeMetadataNode(
    node: String
) -> Result<PrivateKey, DeserializeMetadataNodeError> {
    PrivateKey.bitcoinKeyFromXPriv(xpriv: node)
        .mapError(DeserializeMetadataNodeError.failedToDeserializePrivateKey)
}
