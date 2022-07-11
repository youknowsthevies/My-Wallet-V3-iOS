// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class RecoveryPhraseBadgeInteractor: DefaultBadgeAssetInteractor {

    init(provider: RecoveryPhraseStatusProviding) {
        super.init()
        provider.isRecoveryPhraseVerifiedPublisher
            .asObservable()
            .map { $0 == true ? .confirmed : .unconfirmed }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
