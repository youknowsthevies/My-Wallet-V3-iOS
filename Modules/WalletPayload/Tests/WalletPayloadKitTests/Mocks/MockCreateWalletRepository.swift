// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadDataKit
@testable import WalletPayloadKit

import Combine
import NetworkError

final class MockCreateWalletRepository: CreateWalletRepositoryAPI {

    var createWalletCalled = false
    var createWallerResult: AnyPublisher<Void, NetworkError> = .failure(.serverError(.badResponse))

    func createWallet(
        email: String,
        payload: WalletCreationPayload
    ) -> AnyPublisher<Void, NetworkError> {
        createWalletCalled = true
        return createWallerResult
    }
}
