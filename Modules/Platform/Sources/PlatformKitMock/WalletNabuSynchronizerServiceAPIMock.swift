// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

class WalletNabuSynchronizerServiceAPIMock: WalletNabuSynchronizerServiceAPI {

    func sync() -> AnyPublisher<Void, WalletNabuSynchronizerServiceError> {
        .just(())
    }
}
