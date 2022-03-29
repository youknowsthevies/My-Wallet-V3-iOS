// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum WalletSetup {
    public enum StateError: Error {
        case walletUnitinialized
    }

    public enum State {
        case initialized
        case uninitialized
    }
}

public protocol ReactiveWalletAPI: AnyObject {
    var waitUntilInitializedFirst: AnyPublisher<Void, Never> { get }
    var waitUntilInitialized: AnyPublisher<Void, Never> { get }
    var initializationState: AnyPublisher<WalletSetup.State, Never> { get }
}
