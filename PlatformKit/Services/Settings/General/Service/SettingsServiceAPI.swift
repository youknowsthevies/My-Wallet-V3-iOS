//
//  SettingsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public protocol SettingsServiceAPI: class {
    var valueSingle: Single<WalletSettings> { get }
    var valueObservable: Observable<WalletSettings> { get }
    func fetch() -> Single<WalletSettings>
    
    @available(*, deprecated, message: "Do not use this! Superseded by `fetch()`")
    func refresh()
}

public protocol LastTransactionSettingsUpdateServiceAPI: class {
    func updateLastTransaction() -> Completable
}

public protocol EmailNotificationSettingsServiceAPI: SettingsServiceAPI {
    func emailNotifications(enabled: Bool) -> Completable
}
