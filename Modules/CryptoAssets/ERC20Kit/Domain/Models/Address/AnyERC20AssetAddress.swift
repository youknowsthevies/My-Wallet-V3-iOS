// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public final class AnyERC20AssetAddress<Token: ERC20Token>: AssetAddress {
    public let publicKey: String
    public let cryptoCurrency = Token.assetType
    public init(publicKey: String) {
        self.publicKey = publicKey
    }
}
