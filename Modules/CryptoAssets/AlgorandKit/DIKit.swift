// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var algorandKit = module {

        factory(tag: CryptoCurrency.algorand) { AlgorandAsset() as CryptoAsset }
        
        factory(tag: CryptoCurrency.algorand) { AlgorandCryptoReceiveAddressFactory() as CryptoReceiveAddressFactory }
    }
}
