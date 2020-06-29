//
//  PITConnectionBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class PITConnectionBadgeInteractor: DefaultBadgeAssetInteractor {
    
    init(provider: PITConnectionStatusProviding) {
        super.init()
        provider
            .hasLinkedPITAccount
            .map { $0 == true ? .connected : .connect }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
