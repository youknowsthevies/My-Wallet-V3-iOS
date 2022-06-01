// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol AssetProviderRepositoryAPI {
    func fetchAssetsFromEthereumAddress(
        _ address: String
    ) -> AnyPublisher<[Asset], NabuNetworkError>
}
