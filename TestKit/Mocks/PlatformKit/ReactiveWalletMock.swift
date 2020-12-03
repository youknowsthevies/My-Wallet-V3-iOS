//
//  ReactiveWalletMock.swift
//  TestKit
//
//  Created by Paulo on 14/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class ReactiveWalletMock: ReactiveWalletAPI {
    
    var initializationState: Single<WalletSetup.State> {
        fatalError("Unimplemented")
    }
    
    var waitUntilInitializedSingle: Single<Void> {
        .just(())
    }

    var waitUntilInitialized: Observable<Void> {
        .just(())
    }
}
