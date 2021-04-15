//
//  JWTServiceTests.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import XCTest
import RxSwift

@testable import PlatformKit

final class JWTServiceTests: XCTestCase {
    
    private var service: JWTService!
    private var client: JWTClientMock!
    private var repository: MockWalletRepository!
    
    override func setUp() {
        client = JWTClientMock()
        repository = MockWalletRepository()
    }

    override func tearDown() {
        client = JWTClientMock()
        repository = MockWalletRepository()
        service = nil
    }

    func testSuccessfulTokenFetch() throws {
        
        client.expectedResult = .success("jwt-token")
        
        try repository
            .set(offlineTokenResponse: NabuOfflineTokenResponse(userId: "user-id", token: "offline-token"))
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        try repository
            .set(guid: "guid")
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        try repository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        
        service = JWTService(
            client: client,
            credentialsRepository: repository
        )
        
        XCTAssertEqual(
            try service.token.toBlocking().first(),
            "jwt-token"
        )
    }
    
    func testFailureForMissingCredentials() throws {
        
        client.expectedResult = .success("jwt-token")
        
        try repository
            .set(offlineTokenResponse: NabuOfflineTokenResponse(userId: "user-id", token: "offline-token"))
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        try repository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        
        service = JWTService(
            client: client,
            credentialsRepository: repository
        )
        
        do {
            _ = try service.token.toBlocking().first()
            XCTFail("Expected an error")
        } catch {
            switch error {
            case MissingCredentialsError.guid:
                break
            default:
                XCTFail("Expected an error: \(MissingCredentialsError.guid), got \(error)")
            }
        }
    }
}
 
