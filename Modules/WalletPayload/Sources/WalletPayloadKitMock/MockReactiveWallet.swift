// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

class MockReactiveWallet: ReactiveWalletAPI {

    let mockState = PassthroughSubject<WalletSetup.State, Never>()

    var waitUntilInitializedFirst: AnyPublisher<Void, Never> {
        waitUntilInitialized.first().ignoreFailure()
    }

    var waitUntilInitialized: AnyPublisher<Void, Never> {
        mockState.filter { $0 == .initialized }.mapToVoid().ignoreFailure()
    }

    var initializationState: AnyPublisher<WalletSetup.State, Never> {
        mockState.ignoreFailure()
    }

    init() {}
}
