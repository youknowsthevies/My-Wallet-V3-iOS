// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

final class NoOpWalletPayloadService: WalletPayloadServiceAPI {

    func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        .empty()
    }

    func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        .empty()
    }

    func request(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError> {
        .empty()
    }

    func request(
        guid: String,
        sessionToken: String
    ) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        .empty()
    }
}
