//
//  RecoveryPhraseBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class RecoveryPhraseBadgeInteractor: DefaultBadgeAssetInteractor {

    init(provider: RecoveryPhraseStatusProviding) {
        super.init()
        provider.isRecoveryPhraseVerified
            .map { $0 == true ? .confirmed : .unconfirmed }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

