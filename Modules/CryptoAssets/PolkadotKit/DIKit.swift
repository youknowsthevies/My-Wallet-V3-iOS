// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var polkadotKit = module {

        factory(tag: CryptoCurrency.polkadot) { PolkadotAsset() as CryptoAsset }
        
        factory(tag: CryptoCurrency.polkadot) { PolkadotCryptoReceiveAddressFactory() as CryptoReceiveAddressFactory }
    }
}
