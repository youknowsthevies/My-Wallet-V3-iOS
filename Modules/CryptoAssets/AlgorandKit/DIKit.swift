//
//  DIKit.swift
//  AlgorandKit
//
//  Created by Paulo on 14/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var algorandKit = module {

        factory(tag: CryptoCurrency.algorand) { AlgorandAsset() as CryptoAsset }
        
        factory(tag: CryptoCurrency.algorand) { AlgorandCryptoReceiveAddressFactory() as CryptoReceiveAddressFactory }
    }
}
