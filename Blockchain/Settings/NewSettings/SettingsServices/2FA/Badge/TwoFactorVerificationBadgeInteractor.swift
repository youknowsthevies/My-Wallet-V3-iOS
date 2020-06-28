//
//  TwoFactorVerificationBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class TwoFactorVerificationBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup
    
    init(service: SettingsServiceAPI) {
        super.init()
        service
            .valueObservable
            .map { $0.authenticator.isTwoFactor }
            .map { $0 ? .verified : .unverified }
            .map { .loaded(next: $0) }
            // TODO: Error handing
            .catchErrorJustReturn(.loading)
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
