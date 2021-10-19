// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol AssetLoader {
    func initAndPreload() -> AnyPublisher<Void, Never>

    var loadedAssets: [CryptoAsset] { get }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset { get }
}
