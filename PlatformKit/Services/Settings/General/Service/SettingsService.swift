//
//  SettingsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import ToolKit

public final class SettingsService: SettingsServiceAPI {
    
    // MARK: - Exposed Properties
    
    /// Streams the first available settings element
    public var valueSingle: Single<WalletSettings> {
        valueObservable
            .take(1)
            .asSingle()
    }
    
    public var valueObservable: Observable<WalletSettings> {
        settingsRelay
            .flatMap(weak: self) { (self, settings) -> Observable<WalletSettings> in
                guard let settings = settings else {
                    return self.fetch(force: false).asObservable()
                }
                return .just(settings)
            }
            .distinctUntilChanged()
    }
    
    // MARK: - Private Properties

    private let client: SettingsClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI
    
    private let settingsRelay = BehaviorRelay<WalletSettings?>(value: nil)
    
    private let disposeBag = DisposeBag()
        
    // MARK: - Setup
    
    public init(client: SettingsClientAPI,
                credentialsRepository: CredentialsRepositoryAPI) {
        self.client = client
        self.credentialsRepository = credentialsRepository
        
        NotificationCenter.when(.login) { [weak self] _ in
            self?.settingsRelay.accept(nil)
        }
    }
    
    // MARK: - Public Methods
    
    private let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    private let semaphore = DispatchSemaphore(value: 1)
        
    public func fetch(force: Bool) -> Single<WalletSettings> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.semaphore.wait()
                let disposable = self.settingsRelay
                    .take(1)
                    .asSingle()
                    .flatMap(weak: self) { (self, settings: WalletSettings?) -> Single<WalletSettings> in
                        self.fetchSettings(settings: settings, force: force)
                    }
                    .subscribe { event in
                        switch event {
                        case .success(let settings):
                            observer(.success(settings))
                        case .error(let error):
                            observer(.error(error))
                        }
                    }
                
                return Disposables.create {
                    disposable.dispose()
                    self.semaphore.signal()
                }
            }
            .subscribeOn(scheduler)
    }
    
    private func fetchSettings(settings: WalletSettings?, force: Bool) -> Single<WalletSettings> {
        guard force || settings == nil else { return Single.just(settings!) }
        return credentialsRepository.credentials
            .flatMap(weak: self) { (self, credentials) in
                self.client.settings(
                    by: credentials.guid,
                    sharedKey: credentials.sharedKey
                )
            }
            .map { WalletSettings(response: $0) }
            .do(onSuccess: { [weak self] settings in
                self?.settingsRelay.accept(settings)
            })
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
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    currency: currency.code,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
    
    @available(*, deprecated, message: "Do not use this. Instead use `FiatCurrencyServiceAPI`")
    public var legacyCurrency: FiatCurrency? {
        settingsRelay.value?.currency
    }
}

// MARK: - SettingsEmailUpdateServiceAPI

extension SettingsService: EmailSettingsServiceAPI {

    public var email: Single<String> {
        valueSingle.map { $0.email }
    }
    
    public func update(email: String, context: FlowContext?) -> Completable {
        credentialsRepository.credentials
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
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.updateLastTransactionTime(
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - EmailNotificationSettingsServiceAPI

extension SettingsService: EmailNotificationSettingsServiceAPI {
    public func emailNotifications(enabled: Bool) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.emailNotifications(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - MobileSettingsServiceAPI

extension SettingsService: MobileSettingsServiceAPI {
    public func update(mobileNumber: String) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    smsNumber: mobileNumber,
                    context: .settings,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch(force: true)
        }
        .asCompletable()
    }
    
    public func verify(with code: String) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.verifySMS(
                    code: code,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch(force: true)
        }
        .asCompletable()
    }
}

// MARK: - SMSTwoFactorSettingsServiceAPI

extension SettingsService: SMSTwoFactorSettingsServiceAPI {
    public func smsTwoFactorAuthentication(enabled: Bool) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.smsTwoFactorAuthentication(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
        }
        .flatMapSingle(weak: self) { (self) in
            self.fetch(force: true)
        }
        .asCompletable()
    }
}
