// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ERC20Kit

final class ERC20CryptoAssetServiceMock: ERC20CryptoAssetServiceAPI {

    var initializeCalled: Bool = false

    func initialize() -> AnyPublisher<Void, ERC20CryptoAssetServiceError> {
        initializeCalled = true
        return .just(())
    }
}
