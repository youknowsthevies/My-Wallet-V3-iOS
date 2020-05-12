//
//  SMSVerificationBadgeInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/18/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class MobileVerificationBadgeInteractor: DefaultBadgeAssetInteractor {

    init(service: SettingsServiceAPI) {
        super.init()
        service
            .valueObservable
            .map { $0.isSMSVerified }
            .map { $0 ? .verified : .unverified }
            .map { .loaded(next: $0) }
            // TODO: Error handing
            .catchErrorJustReturn(.loading)
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
