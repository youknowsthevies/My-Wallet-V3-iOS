//
//  ReactiveWalletAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import RxSwift

public struct WalletSetup {
    public enum StateError: Error {
        case walletUnitinialized
    }

    public enum State {
        case initialized
        case uninitialized
    }
}

public protocol ReactiveWalletCombineAPI: class {
    var waitUntilInitializedSinglePublisher: AnyPublisher<Void, Never> { get }
    var waitUntilInitializedStreamPublisher: AnyPublisher<Void, Never> { get }
    var initializationStatePublisher: AnyPublisher<WalletSetup.State, Never> { get }
}

public protocol ReactiveWalletAPI: ReactiveWalletCombineAPI {
    var waitUntilInitializedSingle: Single<Void> { get }
    var waitUntilInitialized: Observable<Void> { get }
    var initializationState: Single<WalletSetup.State> { get }
}
