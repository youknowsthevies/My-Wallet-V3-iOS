// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import MetadataHDWalletKit
import ToolKit

func sign(
    bitcoinMessage message: [UInt8],
    with metadataNode: MetadataNode
) -> Result<String, Error> {
    metadataNode.node.sign(bitcoinMessage: message.toBase64())
}
