// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class MockWalletPayloadService: WalletPayloadServiceAPI {

    func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        .just(.sms)
    }

    func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        .just(())
    }

    func request(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError> {
        .just(())
    }

    func request(guid: String, sessionToken: String) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        .just(.sms)
    }
}
