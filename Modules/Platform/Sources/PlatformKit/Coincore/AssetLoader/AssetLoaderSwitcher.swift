// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import ToolKit

final class AssetLoaderSwitcher: AssetLoader {

    // MARK: Properties

    var loadedAssets: [CryptoAsset] {
        useDynamicLoader ?
            dynamicLoader.loadedAssets
            : staticLoader.loadedAssets
    }

    // MARK: Private Properties

    private let dynamicLoader: DynamicAssetLoader
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI
    private let staticLoader: StaticAssetLoader
    private lazy var useDynamicLoader: Bool = internalFeatureFlagService.isEnabled(.loadAllERC20Tokens)

    // MARK: Init

    init(
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        dynamicLoader: DynamicAssetLoader = .init(),
        staticLoader: StaticAssetLoader = .init()
    ) {
        self.internalFeatureFlagService = internalFeatureFlagService
        self.dynamicLoader = dynamicLoader
        self.staticLoader = staticLoader
    }

    // MARK: Methods

    func initAndPreload() -> AnyPublisher<Void, Never> {
        useDynamicLoader ?
            dynamicLoader.initAndPreload()
            : staticLoader.initAndPreload()
    }

    // MARK: Subscript

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        useDynamicLoader ?
            dynamicLoader[cryptoCurrency]
            : staticLoader[cryptoCurrency]
    }
}
