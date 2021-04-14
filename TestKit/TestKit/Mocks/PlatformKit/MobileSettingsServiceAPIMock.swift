//
//  MobileSettingsServiceAPIMock.swift
//  StellarKitTests
//
//  Created by Paulo on 07/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

class MobileSettingsServiceAPIMock: MobileSettingsServiceAPI {

    var underlyingWalletSettings: WalletSettings!

    var valueSingle: Single<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    var valueObservable: Observable<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    func fetch(force: Bool) -> Single<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    func update(mobileNumber: String) -> Completable {
        .empty()
    }

    func verify(with code: String) -> Completable {
        .empty()
    }
}
