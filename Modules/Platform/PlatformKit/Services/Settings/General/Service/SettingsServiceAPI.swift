//
//  SettingsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public typealias CompleteSettingsServiceAPI = SettingsServiceAPI &
                                              EmailSettingsServiceAPI &
                                              LastTransactionSettingsUpdateServiceAPI &
                                              EmailNotificationSettingsServiceAPI &
                                              FiatCurrencySettingsServiceAPI &
                                              SMSTwoFactorSettingsServiceAPI &
                                              UpdateMobileSettingsServiceAPI &
                                              VerifyMobileSettingsServiceAPI

public typealias MobileSettingsServiceAPI = UpdateMobileSettingsServiceAPI &
                                            VerifyMobileSettingsServiceAPI &
                                            SettingsServiceAPI

public protocol SettingsServiceAPI: AnyObject {
    var valueSingle: Single<WalletSettings> { get }
    var valueObservable: Observable<WalletSettings> { get }
    func fetch(force: Bool) -> Single<WalletSettings>
}

public protocol LastTransactionSettingsUpdateServiceAPI: AnyObject {
    func updateLastTransaction() -> Completable
}

public protocol EmailNotificationSettingsServiceAPI: SettingsServiceAPI {
    func emailNotifications(enabled: Bool) -> Completable
}

public protocol UpdateMobileSettingsServiceAPI {
    func update(mobileNumber: String) -> Completable
}

public protocol VerifyMobileSettingsServiceAPI {
    func verify(with code: String) -> Completable
}

public protocol BalanceSharingSettingsServiceAPI {
    var isEnabled: Observable<Bool> { get }
    func sync()
    func balanceSharing(enabled: Bool) -> Completable
}

public protocol SMSTwoFactorSettingsServiceAPI: SettingsServiceAPI {
    func smsTwoFactorAuthentication(enabled: Bool) -> Completable
}
