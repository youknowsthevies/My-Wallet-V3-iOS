//
//  ReactiveWalletMock.swift
//  TestKit
//
//  Created by Paulo on 14/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import PlatformKit
import RxSwift
import ToolKit

class ReactiveWalletMock: ReactiveWalletAPI {
    
    var waitUntilInitializedSinglePublisher: AnyPublisher<Void, Never> {
        .just(())
    }
    
    var waitUntilInitializedStreamPublisher: AnyPublisher<Void, Never> {
        .just(())
    }
    
    var initializationStatePublisher: AnyPublisher<WalletSetup.State, Never> {
        unimplemented()
    }
    
    var initializationState: Single<WalletSetup.State> {
        unimplemented()
    }
    
    var waitUntilInitializedSingle: Single<Void> {
        .just(())
    }

    var waitUntilInitialized: Observable<Void> {
        .just(())
    }
}
