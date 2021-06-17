// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift
import ToolKit
import XCTest

@testable import Blockchain

/// Tests the pin interactor
class PinInteractorTests: XCTestCase {

    enum Operation {
        case creation
        case validation
    }

    var maintenanceService: MaintenanceServicing {
        WalletServiceMock()
    }

    var wallet: WalletProtocol {
        MockWalletData(initialized: true, delegate: nil)
    }

    var appSettings: MockAppSettings {
        MockAppSettings()
    }

    var credentialsProvider: WalletCredentialsProviding {
        MockWalletCredentialsProvider.valid
    }

    // MARK: - Test success cases

    func testCreation() throws {
        try testPin(operation: .creation)
    }

    func testValidation() throws {
        try testPin(operation: .validation)
    }

    /// Tests PIN operation
    private func testPin(operation: Operation) throws {
        let interactor = PinInteractor(
            credentialsProvider: credentialsProvider,
            pinClient: MockPinClient(statusCode: .success),
            maintenanceService: maintenanceService,
            wallet: wallet,
            appSettings: appSettings
        )
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        switch operation {
        case .creation:
            _ = try interactor.create(using: payload).toBlocking().first()
        case .validation:
            _ = try interactor.validate(using: payload).toBlocking().first()
        }
    }

    // MARK: - Maintenance Error

    func testMaintenanceWhileValidating() throws {
        try testMaintenanceError(for: .validation)
    }

    func testMaintenanceWhileCreating() throws {
        try testMaintenanceError(for: .creation)
    }

    // Maintenance error is returned in the relevant case
    private func testMaintenanceError(for opeation: Operation) throws {
        let expectedMessage = "server under maintenance"
        let maintenanceService = WalletServiceMock()
        maintenanceService.underlyingServerUnderMaintenanceMessage = expectedMessage
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .success),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)

        do {
            switch opeation {
            case .creation:
                _ = try interactor.create(using: payload).toBlocking().first()
            case .validation:
                _ = try interactor.validate(using: payload).toBlocking().first()
            }
            XCTAssert(false)
        } catch {
            let error = error as! PinError
            switch error {
            case .serverMaintenance(message: let message) where message == expectedMessage:
                XCTAssert(true)
            default:
                XCTAssert(false)
            }
        }
    }

    // MARK: - Incorrect PIN validation

    // Incorrect pin returns proper error
    func testIncorrectPinValidation() throws {
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .incorrect),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.incorrectPin {
            XCTAssert(true)
        }
    }

    // Incorrect pin returns correct lock time and update cache correctly
    func testIncorrectPinLockTimeAndCacheUpdate() throws {
        let cache = MemoryCacheSuite()
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .incorrect),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings,
                                       cacheSuite: cache)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)

        // GIVEN: The user entered an incorrect PIN (1st wrong attempt)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        // WHEN: The PIN interactor returns an incorrect error with a lock time
        } catch PinError.incorrectPin(_, let lockTimeSeconds) {
            // THEN: The lock time should equal 10 seconds, cache should records wrong attempt and timestamp
            XCTAssertEqual(lockTimeSeconds, 10)
            XCTAssertEqual(cache.integer(forKey: UserDefaults.Keys.walletWrongPinAttempts.rawValue), 1)
            XCTAssertNotNil(cache.object(forKey: UserDefaults.Keys.walletLastWrongPinTimestamp.rawValue))
        }

        // Simulate incorrect PIN for 2 more times
        for _ in 1...2 {
            do {
                _ = try interactor.validate(using: payload).toBlocking().first()
            } catch PinError.incorrectPin {
                XCTAssert(true)
            }
        }

        // GIVEN: The user entered an incorrect PIN (4th incorrect attempts)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        // WHEN: The PIN interactor returns an incorrect error with a lock time
        } catch PinError.incorrectPin(_, let lockTimeSeconds) {
            // THEN: The lock time should equal 300 seconds, cache should records wrong attempt and timestamp
            XCTAssertEqual(lockTimeSeconds, 300)
            XCTAssertEqual(cache.integer(forKey: UserDefaults.Keys.walletWrongPinAttempts.rawValue), 4)
            XCTAssertNotNil(cache.object(forKey: UserDefaults.Keys.walletLastWrongPinTimestamp.rawValue))
        }

        // GIVEN: The user entered an incorrect PIN (5th incorrect attempts)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        // WHEN: The PIN interactor returns an incorrect error with a lock time
        } catch PinError.incorrectPin(_, let lockTimeSeconds) {
            // THEN: The lock time should equal 3600 seconds, cache should records wrong attempt and timestamp
            XCTAssertEqual(lockTimeSeconds, 3600)
            XCTAssertEqual(cache.integer(forKey: UserDefaults.Keys.walletWrongPinAttempts.rawValue), 5)
            XCTAssertNotNil(cache.object(forKey: UserDefaults.Keys.walletLastWrongPinTimestamp.rawValue))
        }

        // GIVEN: The user entered an incorrect PIN (6th incorrect attempts)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        // WHEN: The PIN interactor returns an incorrect error with a lock time
        } catch PinError.incorrectPin(_, let lockTimeSeconds) {
            // THEN: The lock time should equal 86400 seconds, cache should records wrong attempt and timestamp
            XCTAssertEqual(lockTimeSeconds, 86400)
            XCTAssertEqual(cache.integer(forKey: UserDefaults.Keys.walletWrongPinAttempts.rawValue), 6)
            XCTAssertNotNil(cache.object(forKey: UserDefaults.Keys.walletLastWrongPinTimestamp.rawValue))
        }
    }

    // Too many failed validation attempts
    func testTooManyFailedValidationAttempts() throws {
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .deleted),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.tooManyAttempts {
            XCTAssert(true)
        }
    }

    // MARK: - Backoff Error

    // Backoff error is returned in the relevant case
    func testBackoffError() throws {
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .backoff),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch PinError.backoff {
            XCTAssert(true)
        }
    }

    // Backoff generates a correct remaining lock time
    func testBackoffRemainingLockTime() throws {
        let cache = MemoryCacheSuite()
        let interactorIncorrect = PinInteractor(pinClient: MockPinClient(statusCode: .incorrect),
                                                maintenanceService: maintenanceService,
                                                wallet: wallet,
                                                appSettings: appSettings,
                                                cacheSuite: cache)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)

        // Simulate incorrect PIN for 6 times
        for _ in 1...6 {
            do {
                _ = try interactorIncorrect.validate(using: payload).toBlocking().first()
            } catch PinError.incorrectPin {
                XCTAssert(true)
            }
        }

        let interactorBackoff = PinInteractor(pinClient: MockPinClient(statusCode: .backoff),
                                              maintenanceService: maintenanceService,
                                              wallet: wallet,
                                              appSettings: appSettings,
                                              cacheSuite: cache)

        // GIVEN: The user entered a PIN during locked period (Backoff case)
        do {
            // WHEN: The PIN interactor returns a backoff error with a lock time
            _ = try interactorBackoff.validate(using: payload).toBlocking().first()
        } catch PinError.backoff(_, let remainingLockTime) {
            // THEN: The remainig lock time should be less than or equal to the starting lock time
            // Note that in real-life situation it should be always less than
            XCTAssertTrue(remainingLockTime <= 86400)
        }
    }

    // Invalid status code in response should lead to an exception
    func testFailureOnInvalidStatusCode() throws {
        let interactor = PinInteractor(
            pinClient: MockPinClient(statusCode: nil),
            maintenanceService: maintenanceService,
            wallet: wallet,
            appSettings: appSettings
        )
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)
        do {
            _ = try interactor.validate(using: payload).toBlocking().first()
        } catch {
            XCTAssert(true)
        }
    }

    // Tests the the pin is persisted no app-settings object after validating payload
    func testPersistingPinAfterValidation() throws {
        let settings = MockAppSettings()
        let interactor = PinInteractor(pinClient: MockPinClient(statusCode: .success),
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: settings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: true)
        _ = try interactor.validate(using: payload).toBlocking().first()
        XCTAssertNotNil(settings.pin)
        XCTAssertNotNil(settings.biometryEnabled)
    }

    // Test that an error is thrown in case the server returns an error
    func testServerErrorWhileCreatingPin() throws {
        struct ServerError: Error {}
        let pinClient = MockPinClient(statusCode: .success, error: "server error")
        let interactor = PinInteractor(pinClient: pinClient,
                                       maintenanceService: maintenanceService,
                                       wallet: wallet,
                                       appSettings: appSettings)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: true)
        do {
            _ = try interactor.create(using: payload).toBlocking().first()
            XCTAssert(false)
        } catch {
            XCTAssert(true)
        }
    }

    // Test successful PIN attempt will reset wrong PIN attempts cache
    func testCorrectPinWillResetWrongPinAttempts() throws {
        let cache = MemoryCacheSuite()
        let interactorIncorrect = PinInteractor(pinClient: MockPinClient(statusCode: .incorrect),
                                                maintenanceService: maintenanceService,
                                                wallet: wallet,
                                                appSettings: appSettings,
                                                cacheSuite: cache)
        let payload = PinPayload(pinCode: "1234",
                                 keyPair: try .generateNewKeyPair(),
                                 persistsLocally: false)

        // Simulate an incorrect PIN attempt
        do {
            _ = try interactorIncorrect.validate(using: payload).toBlocking().first()
        } catch PinError.incorrectPin {
            XCTAssert(true)
        }

        let interactorSuccess = PinInteractor(pinClient: MockPinClient(statusCode: .success),
                                              maintenanceService: maintenanceService,
                                              wallet: wallet,
                                              appSettings: appSettings,
                                              cacheSuite: cache)
        do {
            _ = try interactorSuccess.validate(using: payload).toBlocking().first()
            XCTAssertEqual(cache.integer(forKey: UserDefaults.Keys.walletWrongPinAttempts.rawValue), 0)
        } catch {
            XCTAssert(false)
        }
    }
}
