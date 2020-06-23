//
//  SettingsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit

public final class SettingsService: SettingsServiceAPI {
    
    // MARK: - Types

    enum ServiceError: Error {
        case missingSharedKey
        case missingGuid
    }
    
    // MARK: - Exposed Properties
    
    /// Streams the first available settings element
    public var valueSingle: Single<WalletSettings> {
        cachedValue.valueSingle
    }
    
    public var valueObservable: Observable<WalletSettings> {
        cachedValue.valueObservable
    }
    
    // MARK: - Private Properties

    private let client: SettingsClientAPI
    private let credentialsRepository: GuidRepositoryAPI & SharedKeyRepositoryAPI

    private let cachedValue: CachedValue<WalletSettings>
    
    private let disposeBag = DisposeBag()
    
    /// GUID and Shared-Key credentials are necessary to settings operations.
    private var credentials: Single<(guid: String, sharedKey: String)> {
        return Single
            // Make sure guid and shared key exist
            .zip(credentialsRepository.guid, credentialsRepository.sharedKey)
            .map { (guid, sharedKey) -> (guid: String, sharedKey: String) in
                guard let guid = guid else {
                    throw ServiceError.missingGuid
                }
                guard let sharedKey = sharedKey else {
                    throw ServiceError.missingSharedKey
                }
                return (guid, sharedKey)
            }
    }
    
    // MARK: - Setup
    
    public init(client: SettingsClientAPI,
                credentialsRepository: GuidRepositoryAPI & SharedKeyRepositoryAPI) {
        self.client = client
        self.credentialsRepository = credentialsRepository
        
        cachedValue = .init(
            configuration: .init(
                identifier: "settings-service",
                refreshType: .onSubscription,
                fetchPriority: .throttle(
                    milliseconds: 1000,
                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                ),
                fetchNotificationName: .login
            )
        )
        
        cachedValue
            .setFetch(weak: self) { (self) -> Single<WalletSettings> in
                return self.credentials
                    .flatMap(weak: self) { (self, credentials) in
                        self.client.settings(
                            by: credentials.guid,
                            sharedKey: credentials.sharedKey
                        )
                    }
                    .map { WalletSettings(response: $0) }
            }
    }
    
    // MARK: - Public Methods
    
    public func fetch() -> Single<WalletSettings> {
        cachedValue.fetchValue
    }
    
    @available(*, deprecated, message: "Do not use this! Superseded by `fetch()`")
    public func refresh() {
        fetch()
            .subscribe()
            .disposed(by: disposeBag)
    }
}

// MARK: - FiatCurrencySettingsServiceAPI

extension SettingsService: FiatCurrencySettingsServiceAPI {

    public var fiatCurrencyObservable: Observable<FiatCurrency> {
        valueObservable
            .map { settings -> FiatCurrency in
                guard let currency = FiatCurrency(rawValue: settings.fiatCurrency) else {
                    throw PlatformKitError.default
                }
                return currency
            }
            .distinctUntilChanged()
    }
    
    public var fiatCurrency: Single<FiatCurrency> {
        valueSingle
            .map { settings -> FiatCurrency in
                guard let currency = settings.currency else {
                    throw PlatformKitError.default
                }
                return currency
            }
    }
    
    public func update(currency: FiatCurrency, context: FlowContext) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    currency: currency.code,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch()
            }
            .asCompletable()
    }
    
    @available(*, deprecated, message: "Do not use this. Instead use `FiatCurrencySettingsServiceAPI`")
    public var legacyCurrency: FiatCurrency? {
        cachedValue.legacyValue?.currency
    }
}

// MARK: - SettingsEmailUpdateServiceAPI

extension SettingsService: EmailSettingsServiceAPI {

    public var email: Single<String> {
        valueSingle.map { $0.email }
    }
    
    public func update(email: String, context: FlowContext?) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    email: email,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
    }
}

// MARK: - LastTransactionSettingsUpdateServiceAPI

extension SettingsService: LastTransactionSettingsUpdateServiceAPI {
    public func updateLastTransaction() -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.updateLastTransactionTime(
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch()
            }
            .asCompletable()
    }
}

// MARK: - EmailNotificationSettingsServiceAPI

extension SettingsService: EmailNotificationSettingsServiceAPI {
    public func emailNotifications(enabled: Bool) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.emailNotifications(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch()
            }
            .asCompletable()
    }
}

// MARK: - MobileSettingsServiceAPI

extension SettingsService: MobileSettingsServiceAPI {
    public func update(mobileNumber: String) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    smsNumber: mobileNumber,
                    context: .settings,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch()
        }
        .asCompletable()
    }
    
    public func verify(with code: String) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.verifySMS(
                    code: code,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch()
        }
        .asCompletable()
    }
}

// MARK: - SMSTwoFactorSettingsServiceAPI

extension SettingsService: SMSTwoFactorSettingsServiceAPI {
    public func smsTwoFactorAuthentication(enabled: Bool) -> Completable {
        credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.smsTwoFactorAuthentication(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch()
        }
        .asCompletable()
    }
}
