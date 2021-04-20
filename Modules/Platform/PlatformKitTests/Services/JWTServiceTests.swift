//
//  JWTServiceTests.swift
//  PlatformKitTests
//
//  Created by Daniel on 30/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import XCTest
import RxSwift

@testable import PlatformKit

final class JWTServiceTests: XCTestCase {
   
    private var cancellables: Set<AnyCancellable>!
    private var subject: JWTService!
    private var client: JWTClientMock!
    private var repository: MockWalletRepository!
    
    override func setUp() {
        super.setUp()
        
        client = JWTClientMock()
        repository = MockWalletRepository()
        subject = JWTService(
            client: client,
            credentialsRepository: repository
        )
        cancellables = Set<AnyCancellable>([])
    }

    override func tearDown() {
        client = nil
        repository = nil
        subject = nil
        cancellables = nil
        
        super.tearDown()
    }

    func testSuccessfulTokenFetch() throws {
        
        // Arrange
        client.expectedResult = .success("jwt-token")
        
        let offlineTokenResponse = NabuOfflineTokenResponse(
            userId: "user-id",
            token: "offline-token"
        )
        
        try repository
            .set(offlineTokenResponse: offlineTokenResponse)
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
        
        let correctTokenSetExpectation = self.expectation(
            description: "Correct token set"
        )
        
        // Act
        subject.token
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        XCTFail("failed w/ error: \(error)")
                    }
                },
                receiveValue: { token in
                    XCTAssertEqual(token, "jwt-token")
                    correctTokenSetExpectation.fulfill()
                }
            )
            .store(in: &cancellables)
            
        // Assert
        wait(
            for: [
                correctTokenSetExpectation
            ],
            timeout: 5,
            enforceOrder: true
        )
    }
    
    func testFailureForMissingCredentials() throws {
        
        // Arrange
        client.expectedResult = .success("jwt-token")
        
        let offlineTokenResponse = NabuOfflineTokenResponse(
            userId: "user-id",
            token: "offline-token"
        )
        
        try repository
            .set(offlineTokenResponse: offlineTokenResponse)
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        try repository
            .set(sharedKey: "shared-key")
            .andThen(Single.just(()))
            .toBlocking()
            .first()
        
        let missingCredentialsErrorExpectation = self.expectation(
            description: "Expect a missing credentials error"
        )
        
        // Act
        subject.token
            .sink(
                receiveCompletion: { completion in
                    guard case .failure(let error) = completion else {
                        XCTFail("Expected an error")
                        return
                    }
                    guard case .failedToRetrieveCredentials(let credentialsError) = error else {
                        XCTFail("Expected a failed to retrieve credentials error")
                        return
                    }
                    guard let missingCredentialsError = credentialsError as? MissingCredentialsError else {
                        XCTFail("Expected a failed to retrieve credentials error")
                        return
                    }
                    guard missingCredentialsError == .guid else {
                        XCTFail("Expected a failed to retrieve guid error")
                        return
                    }
                    missingCredentialsErrorExpectation.fulfill()
                },
                receiveValue: { _ in
                    XCTFail("Expected an error")
                }
            )
            .store(in: &cancellables)
            
        // Assert
        wait(
            for: [
                missingCredentialsErrorExpectation
            ],
            timeout: 5,
            enforceOrder: true
        )
    }
}
 
