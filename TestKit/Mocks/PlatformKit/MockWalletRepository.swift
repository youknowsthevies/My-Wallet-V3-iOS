//
//  MockWalletRepository.swift
//  PlatformKitTests
//
//  Created by Daniel Huri on 10/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

@testable import PlatformKit

final class MockWalletRepository: WalletRepositoryAPI {
    private var expectedSessionToken: String?
    private var expectedAuthenticatorType: AuthenticatorType = .standard
    private var expectedGuid: String?
    private var expectedPayload: String?
    private var expectedSharedKey: String?
    private var expectedPassword: String?
    private var expectedSyncPubKeys = false
    var expectedOfflineTokenResponse: Result<NabuOfflineTokenResponse, MissingCredentialsError>!

    var sessionToken: Single<String?> { .just(expectedSessionToken) }
    var payload: Single<String?> { .just(expectedPayload) }
    var sharedKey: Single<String?> { .just(expectedSharedKey) }
    var password: Single<String?> { .just(expectedPassword) }
    var guid: Single<String?> { .just(expectedGuid) }
    var authenticatorType: Single<AuthenticatorType> { .just(expectedAuthenticatorType) }
    var offlineTokenResponse: Single<NabuOfflineTokenResponse> {
        expectedOfflineTokenResponse.single
    }
    
    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable {
        return perform { [weak self] in
            self?.expectedOfflineTokenResponse = .success(offlineTokenResponse)
        }
    }
    
    func set(sessionToken: String) -> Completable {
        perform { [weak self] in
            self?.expectedSessionToken = sessionToken
        }
    }
    
    func set(sharedKey: String) -> Completable {
        perform { [weak self] in
            self?.expectedSharedKey = sharedKey
        }
    }
    
    func set(password: String) -> Completable {
        perform { [weak self] in
            self?.expectedPassword = password
        }
    }

    func set(guid: String) -> Completable {
        perform { [weak self] in
            self?.expectedGuid = guid
        }
    }
    
    func set(syncPubKeys: Bool) -> Completable {
        perform { [weak self] in
            self?.expectedSyncPubKeys = syncPubKeys
        }
    }
    
    func set(language: String) -> Completable {
        .empty()
    }
    
    func set(authenticatorType: AuthenticatorType) -> Completable {
        perform { [weak self] in
            self?.expectedAuthenticatorType = authenticatorType
        }
    }
    
    func set(payload: String) -> Completable {
        perform { [weak self] in
            self?.expectedPayload = payload
        }
    }
    
    func cleanSessionToken() -> Completable {
        perform { [weak self] in
            self?.expectedSessionToken = nil
        }
    }

    func sync() -> Completable {
        perform { }
    }

    private func perform(_ operation: @escaping () -> Void) -> Completable {
        Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
    }
}
