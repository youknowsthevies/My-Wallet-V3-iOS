// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
import TestKit
import ToolKit
@testable import WalletPayloadDataKit
@testable import WalletPayloadKit
@testable import WalletPayloadKitMock
import XCTest

class WalletPayloadServiceTests: XCTestCase {

    /// Tests a valid response to payload fetching that requires 2FA code
    func testValid2FAResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.sms // expect SMS
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: nil
        )
        let walletRepository = MockWalletRepository()

        let sessionTokenSetPublisher = walletRepository.set(sessionToken: "1234-abcd-5678-efgh")
        let guidSetPublisher = walletRepository.set(guid: "fake-guid")
        XCTAssertPublisherCompletion([sessionTokenSetPublisher, guidSetPublisher])

        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let repository = WalletPayloadRepository(apiClient: client)
        let walletRepo = WalletRepo(initialState: .empty)
        let nativeWalletEnabled = false
        let nativeWalletEnabledUseImpl: NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI> =
            { old, new -> AnyPublisher<Either<WalletPayloadServiceAPI, WalletPayloadServiceAPI>, Never> in
                guard nativeWalletEnabled else {
                    return .just(Either.left(old))
                }
                return .just(Either.right(new))
            }
        let guidRepo = GuidRepository(
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            nativeWalletEnabled: { .just(nativeWalletEnabled) }
        )
        let sharedKeyRepo = SharedKeyRepository(
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            nativeWalletEnabled: { .just(nativeWalletEnabled) }
        )
        let credentialsRepository = CredentialsRepository(
            guidRepository: guidRepo,
            sharedKeyRepository: sharedKeyRepo
        )
        let service = WalletPayloadService(
            repository: repository,
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            credentialsRepository: credentialsRepository,
            nativeWalletEnabledUse: nativeWalletEnabledUseImpl
        )
        let serviceAuthTypePublisher = service.requestUsingSessionToken()
        XCTAssertPublisherValues(serviceAuthTypePublisher, expectedAuthType, timeout: 5.0)

        let repositoryAuthTypePublisher = walletRepository.authenticatorType
        XCTAssertPublisherValues(repositoryAuthTypePublisher, expectedAuthType, timeout: 5.0)
    }

    func testValidPayloadResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.standard // expect no 2FA
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}"
        )
        let walletRepository = MockWalletRepository()

        let sessionTokenSetPublisher = walletRepository.set(sessionToken: "1234-abcd-5678-efgh")
        let guidSetPublisher = walletRepository.set(guid: "fake-guid")
        XCTAssertPublisherCompletion([sessionTokenSetPublisher, guidSetPublisher])

        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let repository = WalletPayloadRepository(apiClient: client)
        let walletRepo = WalletRepo(initialState: .empty)
        let nativeWalletEnabled = false
        let nativeWalletEnabledUseImpl: NativeWalletEnabledUseImpl<WalletPayloadServiceAPI, WalletPayloadServiceAPI> =
            { old, new -> AnyPublisher<Either<WalletPayloadServiceAPI, WalletPayloadServiceAPI>, Never> in
                guard nativeWalletEnabled else {
                    return .just(Either.left(old))
                }
                return .just(Either.right(new))
            }
        let guidRepo = GuidRepository(
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            nativeWalletEnabled: { .just(nativeWalletEnabled) }
        )
        let sharedKeyRepo = SharedKeyRepository(
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            nativeWalletEnabled: { .just(nativeWalletEnabled) }
        )
        let credentialsRepository = CredentialsRepository(
            guidRepository: guidRepo,
            sharedKeyRepository: sharedKeyRepo
        )
        let service = WalletPayloadService(
            repository: repository,
            walletRepository: walletRepository,
            walletRepo: walletRepo,
            credentialsRepository: credentialsRepository,
            nativeWalletEnabledUse: nativeWalletEnabledUseImpl
        )
        let serviceAuthTypePublisher = service.requestUsingSessionToken()
        XCTAssertPublisherValues(serviceAuthTypePublisher, expectedAuthType, timeout: 5.0)

        let repositoryAuthTypePublisher = walletRepository.authenticatorType
        XCTAssertPublisherValues(repositoryAuthTypePublisher, expectedAuthType, timeout: 5.0)
        XCTAssertPublisherValues(walletRepository.payload, walletRepository.expectedPayload, timeout: 5.0)
    }
}
