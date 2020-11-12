//
//  NabuAuthenticationExecutorTests.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift

@testable import PlatformKit
@testable import NetworkKit

final class NabuAuthenticationExecutorTests: XCTestCase {

    private var userCreationClient: UserCreationClientMock!
    private var authenticationClient: NabuAuthenticationClientMock!
    private var store: NabuTokenStore!
    private var settingsService: SettingsServiceMock!
    private var siftService: SiftServiceMock!
    private var jwtService: JWTServiceMock!
    private var walletRepository: MockWalletRepository!
    private var deviceInfo: MockDeviceInfo!
    private var executor: NabuAuthenticationExecutor!
    
    override func setUp() {
        userCreationClient = UserCreationClientMock()
        authenticationClient = NabuAuthenticationClientMock()
        store = NabuTokenStore()
        settingsService = SettingsServiceMock()
        siftService = SiftServiceMock()
        jwtService = JWTServiceMock()
        walletRepository = MockWalletRepository()
        deviceInfo = MockDeviceInfo(systemVersion: "1.2.3", model: "iPhone5S", uuidString: "uuid")
        
        executor = NabuAuthenticationExecutor(
            userCreationClient: userCreationClient,
            store: store,
            settingsService: settingsService,
//            siftService: siftService,
            jwtService: jwtService,
            authenticationClient: authenticationClient,
            credentialsRepository: walletRepository,
            deviceInfo: deviceInfo
        )
    }
    
    func testSuccessfulAuthenticationWhenUserIsAlreadyCreated() throws {
        
        let expectedSessionTokenValue = "session-token"
        
        let offlineTokenResponse = NabuOfflineTokenResponse(userId: "user-id", token: "offline-token")
        
        jwtService.expectedResult = .success("jwt-token")
        
        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )
        
        try walletRepository
            .set(offlineTokenResponse: offlineTokenResponse)
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        authenticationClient.expectedSessionTokenResult = .success(
            NabuSessionTokenResponse(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )
        try walletRepository
            .set(guid: "guid")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        try walletRepository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        
        let token = try executor
            .authenticate { Single.just($0) }
            .toBlocking()
            .first()
        
        XCTAssertEqual(token, expectedSessionTokenValue)
    }
    
    func testSuccessfulAuthenticationWhenUserIsNotCreated() throws {
        
        let expectedSessionTokenValue = "session-token"
        
        let offlineTokenResponse = NabuOfflineTokenResponse(userId: "user-id", token: "offline-token")
        
        // Offline token is missing - user creation will be attempted
        walletRepository.expectedOfflineTokenResponse = .failure(.offlineToken)
        jwtService.expectedResult = .success("jwt-token")
        userCreationClient.expectedResult = .success(offlineTokenResponse)
        
        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )
        
        authenticationClient.expectedSessionTokenResult = .success(
            NabuSessionTokenResponse(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )
        try walletRepository
            .set(guid: "guid")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        try walletRepository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        
        let token = try executor
            .authenticate { Single.just($0) }
            .toBlocking()
            .first()
        
        XCTAssertEqual(token, expectedSessionTokenValue)
        XCTAssertEqual(
            try walletRepository.offlineTokenResponse.toBlocking().first(),
            offlineTokenResponse
        )
    }
    
    func testExpiredTokenAndSecondSuccessfulAuthentication() throws {
        
        let offlineTokenResponse = NabuOfflineTokenResponse(
            userId: "user-id",
            token: "offline-token"
        )
        
        let expiredSessionTokenResponse = NabuSessionTokenResponse(
            identifier: "identifier",
            userId: "user-id",
            token: "expired-session-token",
            isActive: true,
            expiresAt: Date.distantPast
        )
        
        let newSessionTokenResponse = NabuSessionTokenResponse(
            identifier: "identifier",
            userId: "user-id",
            token: "new-session-token",
            isActive: true,
            expiresAt: Date.distantFuture
        )
        
        // Store expired session token
        try _ = store.store(expiredSessionTokenResponse).toBlocking().first()

        jwtService.expectedResult = .success("jwt-token")
        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )
        
        authenticationClient.expectedSessionTokenResult = .success(newSessionTokenResponse)
        
        try walletRepository
            .set(offlineTokenResponse: offlineTokenResponse)
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        
        try walletRepository
            .set(guid: "guid")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        try walletRepository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
                .toBlocking()
                .first()
        
        let token = try executor
            .authenticate { (token: String) -> Single<String> in
                if token == newSessionTokenResponse.token {
                    return Single.just(token)
                } else {
                    let httpResponse = HTTPURLResponse(
                        url: URL(string: "https://www.blockchain.com")!,
                        statusCode: NabuAPIError.tokenExpired.rawValue,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    let response = ServerErrorResponse(response: httpResponse, payload: nil)
                    return Single.error(NetworkCommunicatorError.rawServerError(response))
                }
            }
            .toBlocking()
            .first()
        
        XCTAssertEqual(token, newSessionTokenResponse.token)
    }
}


