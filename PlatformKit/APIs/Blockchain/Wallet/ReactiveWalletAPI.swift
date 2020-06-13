//
//  ReactiveWalletAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

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

public protocol ReactiveWalletAPI: class {
    var waitUntilInitializedSingle: Single<Void> { get }
    var waitUntilInitialized: Observable<Void> { get }
}
